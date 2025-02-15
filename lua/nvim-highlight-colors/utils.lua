local colors = require("nvim-highlight-colors.color.utils")
local table_utils = require("nvim-highlight-colors.table_utils")

local M = {
	render_options = {
		background = "background",
		foreground = "foreground",
		virtual = 'virtual'
	}
}

---Returns the last row index of the current buffer
---@return number
function M.get_last_row_index()
	return vim.fn.line('$')
end

---Returns a range of visible rows of the specified buffer
---@param buffer_id number
---@return table {first_line_index, last_line_index}
function M.get_visible_rows_by_buffer_id(buffer_id)
	local window_id = vim.fn.bufwinid(buffer_id)

	return vim.api.nvim_win_call(
		window_id ~= -1 and window_id or 0,
		function()
			return {
				vim.fn.line('w0'),
				vim.fn.line('w$')
			}
		end
	)
end

---Returns a highlight name that can be used as a group highlight
---@param color_value string
---@return string
function M.create_highlight_name(color_value)
	return 'nvim-highlight-colors-' .. string.gsub(color_value, "#", ""):gsub("[!(),%s%.-/%%=:\"'%%;#]+", "")
end

---Creates the highlight based on the received params
---@param active_buffer_id number
---@param ns_id number
---@param data {row: number, start_column: number, end_column: number, value: string}
---@param options {custom_colors: table, render: string, virtual_symbol: string, virtual_symbol_prefix: string, virtual_symbol_suffix: string, virtual_symbol_position: 'inline' | 'eol' | 'eow', enable_short_hex: boolean}
---
---For `options.custom_colors`, a table with the following structure is expected:
---* `label`: A string representing a template for the color name, likely using placeholders for the theme name. (e.g., '%-%-theme%-primary%-color')
---* `color`: A string representing the actual color value in a valid format (e.g., '#0f1219').
function M.create_highlight(active_buffer_id, ns_id, data, options)
	local color_value = colors.get_color_value(data.value, 2, options.custom_colors, options.enable_short_hex)

	if color_value == nil then
		return
	end

	local highlight_group = M.create_highlight_name(options.render .. data.value .. color_value)

	if options.render == M.render_options.background then
		local foreground_color = colors.get_foreground_color_from_hex_color(color_value)
		pcall(vim.api.nvim_set_hl, 0, highlight_group, {
			fg = foreground_color,
			bg = color_value,
			default = true,
		})
	else
		pcall(vim.api.nvim_set_hl, 0, highlight_group, {
			fg = color_value,
			default = true,
		})
	end

	if options.render == M.render_options.virtual then
		pcall(
			M.highlight_extmarks,
			active_buffer_id,
			ns_id,
			data,
			highlight_group,
			options
		)
		return
	end
	pcall(
		function()
			vim.api.nvim_buf_add_highlight(
				active_buffer_id,
				ns_id,
				highlight_group,
				data.row + 1,
				data.start_column,
				data.end_column
			)
		end
	)
end

---Highlights extmarks 
---@param active_buffer_id number
---@param ns_id number
---@param data {row: number, start_column: number, end_column: number, value: string}
---@param highlight_group string
---@param options {custom_colors: table, render: string, virtual_symbol: string, virtual_symbol_prefix: string, virtual_symbol_suffix: string, virtual_symbol_position: 'inline' | 'eol' | 'eow', enable_short_hex: boolean}
function M.highlight_extmarks(active_buffer_id, ns_id, data, highlight_group, options)
	local start_extmark_row = data.row + 1
	local start_extmark_column = data.start_column - 1
	local virtual_text_position = M.get_virtual_text_position(options)
	local virtual_text_column = M.get_virtual_text_column(
		virtual_text_position,
		start_extmark_column,
		data.end_column
	)
	local already_highlighted_extmark = vim.api.nvim_buf_get_extmarks(
		active_buffer_id,
		ns_id,
		{start_extmark_row, start_extmark_column},
		{start_extmark_row, virtual_text_column},
		{details = true}
	)
	local is_already_highlighted = #table_utils.filter(
		already_highlighted_extmark,
		function (extmark)
			local extmark_data = vim.deepcopy(extmark[4])
			local extmark_highlight_group = extmark_data.virt_text[1][2]
			return extmark_highlight_group == highlight_group
		end
	) > 0
	if (is_already_highlighted) then
		return
	end

	-- Delete currently shown extmarks in this same position
	for _, extmark in pairs(already_highlighted_extmark) do
		pcall(
			vim.api.nvim_buf_del_extmark,
			active_buffer_id,
			ns_id,
			extmark[1]
		)
	end

	vim.api.nvim_buf_set_extmark(
		active_buffer_id,
		ns_id,
		start_extmark_row,
		virtual_text_column,
		{

			virt_text_pos = virtual_text_position == 'eow' and 'inline' or virtual_text_position,
			virt_text = {{
				options.virtual_symbol_prefix .. options.virtual_symbol .. options.virtual_symbol_suffix,
				vim.api.nvim_get_hl_id_by_name(highlight_group)
			}},
			hl_mode = "combine",
		}
	)
end

---Returns the virtual text(extmark) position based on the user preferences
---@param options {virtual_symbol_position: 'inline' | 'eol' | 'eow'}
---@return 'inline' | 'eol' | 'eow'
function M.get_virtual_text_position(options)
	local nvim_version = vim.version()

	-- Safe guard for older neovim versions
	if nvim_version.major == 0 and nvim_version.minor < 10 then
		return 'eol'
	end

	return options.virtual_symbol_position
end

---Returns the virtual text(extmark) column index position based on the user preferences
---@param virtual_text_position 'inline' | 'eol' | 'eow'
---@param start_extmark_column number
---@param end_extmark_column number
---@return number
function M.get_virtual_text_column(virtual_text_position, start_extmark_column, end_extmark_column)
	if virtual_text_position == 'eol' then
		return start_extmark_column
	end

	if virtual_text_position == 'eow' then
		return end_extmark_column
	end

	return start_extmark_column + 1
end

---Highlights colors based on connected LSPs
---@param active_buffer_id number
---@param ns_id number
---@param positions {row: number, start_column: number, end_column: number, value: string}[]
---@param options {custom_colors: table, render: string, virtual_symbol: string, virtual_symbol_prefix: string, virtual_symbol_suffix: string, virtual_symbol_position: 'inline' | 'eol' | 'eow', enable_short_hex: boolean}
function M.highlight_with_lsp(active_buffer_id, ns_id, positions, options)
	local param = { textDocument = vim.lsp.util.make_text_document_params() }
	local clients = M.get_lsp_clients()

	for _, client in pairs(clients) do
		if client.server_capabilities.colorProvider then
			client.request(
				"textDocument/documentColor",
				param,
				function(_, response)
					M.highlight_lsp_document_color(
						response,
						active_buffer_id,
						ns_id,
						positions,
						options
					)
				end,
				active_buffer_id
			)
		end
	end
end

---Highlights colors for request 'textDocument/documentColor'
---@param response table Table array of {color: {red: number, green: number, blue: number, alpha: number}, range: {start: {character: number}, end: {character: number}}
---@param active_buffer_id number
---@param ns_id number
---@param positions {row: number, start_column: number, end_column: number, value: string}[]
---@param options {custom_colors: table, render: string, virtual_symbol: string, virtual_symbol_prefix: string, virtual_symbol_suffix: string, virtual_symbol_position: 'inline' | 'eol' | 'eow', enable_short_hex: boolean}
function M.highlight_lsp_document_color(response, active_buffer_id, ns_id, positions, options)
	local results = {}
	if response == nil then
		return
	end

	for _, match in pairs(response) do
		local r, g, b, a =
			match.color.red or 0, match.color.green or 0, match.color.blue or 0, match.color.alpha or 0
		local value = string.format("#%02x%02x%02x", r * a * 255, g * a * 255, b * a * 255)
		local range = match.range
		local start_column = range.start.character
		local end_column = range["end"].character
		local row = range.start.line - 1
		local is_already_highlighted = #table_utils.filter(
			positions,
			function(position)
				return position.start_column == start_column
					and position.end_column == end_column
					and position.row == row
					and position.value == value
			end
		) > 0

		local result = {
			row = row,
			start_column = start_column,
			end_column = end_column,
			value = value,
		}

		if (not is_already_highlighted) then
			M.create_highlight(
				active_buffer_id,
				ns_id,
				result,
				options
			)
		end
		table.insert(results, result)
	end

	return results
end

---Returns a boolean indicating if tailwindcss LSP is connected
---@return boolean
function M.has_tailwind_css_lsp()
	local clients = M.get_lsp_clients()
	for _, client in pairs(clients) do
		if client.name == 'tailwindcss' then
			return true
		end
	end

	return false
end

---Get active LSP clients
---@return vim.lsp.Client[]
function M.get_lsp_clients()
	local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
	return get_clients()
end

return M
