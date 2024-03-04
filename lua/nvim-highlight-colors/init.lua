local utils = require("nvim-highlight-colors.utils")
local table_utils = require("nvim-highlight-colors.table_utils")
local buffer_utils = require("nvim-highlight-colors.buffer_utils")
local colors = require("nvim-highlight-colors.color.utils")
local color_patterns = require("nvim-highlight-colors.color.patterns")
local ns_id = vim.api.nvim_create_namespace("nvim-highlight-colors")

if vim.g.loaded_nvim_highlight_colors ~= nil then
	return {}
end
vim.g.loaded_nvim_highlight_colors = 1

local render_options = utils.render_options
local row_offset = 2
local is_loaded = false
local options = {
	render = render_options.background,
	enable_named_colors = true,
	enable_tailwind = false,
	custom_colors = nil,
}

local M = {}

function M.setup(user_options)
	is_loaded = true
	if (user_options ~= nil and user_options ~= {}) then
		for key, _ in pairs(user_options) do
			if user_options[key] ~= nil then
				options[key] = user_options[key]
			end
		end
	end
end

function M.highlight_colors(min_row, max_row, active_buffer_id)
	local patterns = {
		color_patterns.hex_regex,
		color_patterns.hex_0x_regex,
		color_patterns.rgb_regex,
		color_patterns.hsl_regex,
		color_patterns.var_usage_regex,
	}

	if options.enable_named_colors then
	       table.insert(patterns, colors.get_css_named_color_pattern())
	end

	if options.enable_tailwind then
	       table.insert(patterns, colors.get_tailwind_named_color_pattern())
	end

	if (options.custom_colors ~= nil) then
		for _, custom_color in pairs(options.custom_colors) do
			table.insert(patterns, custom_color.label)
		end
	end

	local positions = buffer_utils.get_positions_by_regex(
		patterns,
		min_row - 1,
		max_row,
		active_buffer_id,
		row_offset
	)

	for _, data in pairs(positions) do
		utils.create_highlight(
			active_buffer_id,
			ns_id,
			data.row,
			data.start_column,
			data.end_column,
			data.value,
			options.render,
			options.custom_colors
		)
	end
end

function M.refresh_highlights(active_buffer_id)
	local buffer_id = active_buffer_id ~= nil and active_buffer_id or 0

	M.clear_highlights(buffer_id)
	local visible_rows = utils.get_visible_rows_by_buffer_id(buffer_id)
	local min_row = visible_rows[1]
	local max_row = visible_rows[2]
	M.highlight_colors(min_row, max_row, buffer_id)
end

function M.turn_on()
	local buffers = vim.fn.getbufinfo({ buflisted = true })

	for _, buffer in ipairs(buffers) do
		M.refresh_highlights(buffer.bufnr)
	end

	is_loaded = true
end

function M.turn_off()
	local buffers = vim.fn.getbufinfo({ buflisted = true })

	for _, buffer in ipairs(buffers) do
		M.clear_highlights(buffer.bufnr)
	end

	is_loaded = false
end

function M.clear_highlights(active_buffer_id)
	local buffer_id = active_buffer_id ~= nil and active_buffer_id or 0

	vim.api.nvim_buf_clear_namespace(buffer_id, ns_id, 0, utils.get_last_row_index())
	local virtual_texts = vim.api.nvim_buf_get_extmarks(buffer_id, ns_id, 0, -1, {})

	if #virtual_texts then
		for _, virtual_text in pairs(virtual_texts) do
			local extmart_id = virtual_text[1]
			if (tonumber(extmart_id) ~= nil) then
				vim.api.nvim_buf_del_extmark(buffer_id, ns_id, extmart_id)
			end
		end
	end
end

function M.toggle()
	if is_loaded then
		M.turn_off()
	else
		M.turn_on()
	end
end

function M.handle_autocmd_callback(props)
	if is_loaded then
		M.refresh_highlights(props.buf)
	end
end

vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP", "VimResized"}, {
	callback = M.handle_autocmd_callback,
})

vim.api.nvim_create_autocmd({"WinScrolled"}, {
	callback = M.handle_autocmd_callback,
})

vim.api.nvim_create_autocmd({"BufEnter"}, {
	callback = M.handle_autocmd_callback,
})

vim.api.nvim_create_user_command("HighlightColors",
	function(opts)
		local arg = string.lower(opts.fargs[1])
		if arg == "on" then
			M.turn_on()
		elseif arg == "off" then
			M.turn_off()
		elseif arg == "toggle" then
			M.toggle()
		end
	end,
	{
		nargs = 1,
		complete = function()
			return { "On", "Off", "Toggle" }
		end,
		desc = "Config color highlight"
	}
)

utils.deprecate()

return {
	turnOff = M.turn_off,
	turnOn = M.turn_on,
	setup = M.setup,
	toggle = M.toggle,
}
