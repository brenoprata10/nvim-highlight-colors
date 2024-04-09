local colors = require("nvim-highlight-colors.color.utils")
local table_utils = require("nvim-highlight-colors.table_utils")

local M = {
	render_options = {
		background = "background",
		foreground = "foreground",
		virtual = 'virtual'
	}
}

function M.get_last_row_index()
	return vim.fn.line('$')
end

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

local function create_highlight_name(color_value)
	return string.gsub(color_value, "#", ""):gsub("[(),%s%.-/%%=:\"']+", "")
end

function M.create_highlight(active_buffer_id, ns_id, row, start_column, end_column, color, render_option, custom_colors, virtual_symbol)
	local highlight_group = create_highlight_name(color)
	local color_value = colors.get_color_value(color, 2, custom_colors)

	if color_value == nil then
		return
	end

	if render_option == M.render_options.background then
		local foreground_color = colors.get_foreground_color_from_hex_color(color_value)
		pcall(vim.api.nvim_set_hl, 0, highlight_group, {
            		fg = foreground_color,
            		bg = color_value
        	})
	else
		pcall(vim.api.nvim_set_hl, 0, highlight_group, {
            		fg = color_value
        	})
	end

	if render_option == M.render_options.virtual then
		local start_extmark_row = row + 1
		local start_extmark_column = start_column - 1
		local end_extmark_column = end_column - 1

		local is_already_highlighted = #vim.api.nvim_buf_get_extmarks(
			active_buffer_id,
			ns_id,
			{start_extmark_row, start_extmark_column},
			{start_extmark_row, end_extmark_column},
			{}
		) > 0
		if (is_already_highlighted) then
			return
		end
		pcall(
			function()
				vim.api.nvim_buf_set_extmark(
					active_buffer_id,
					ns_id,
					start_extmark_row,
					start_extmark_column,
					{
						virt_text = {{virtual_symbol, vim.api.nvim_get_hl_id_by_name(highlight_group)}},
						hl_mode = "combine",
					}
				)
			end
		)
		return
	end
	vim.api.nvim_buf_add_highlight(
		active_buffer_id,
		ns_id,
		highlight_group,
		row + 1,
		start_column,
		end_column
	)
end

function M.highlight_with_lsp(active_buffer_id, ns_id, positions, options)
	local param = { textDocument = vim.lsp.util.make_text_document_params() }
	local clients = vim.lsp.get_active_clients()
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

function M.highlight_lsp_document_color(response, active_buffer_id, ns_id, positions, options)
	if response == nil then
		return
	end

	for _, match in pairs(response) do
		local r, g, b, a =
			match.color.red or 0, match.color.green or 0, match.color.blue or 0, match.color.alpha or 0
		local color = string.format("#%02x%02x%02x", r * a * 255, g * a * 255, b * a * 255)
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
			end
		) > 0

		if (not is_already_highlighted) then
			M.create_highlight(
				active_buffer_id,
				ns_id,
				row,
				start_column,
				end_column,
				color,
				options.render,
				options.custom_colors,
				options.virtual_symbol
			)
		end
	end
end

return M
