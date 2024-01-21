local utils = require("nvim-highlight-colors.utils")
local buffer_utils = require("nvim-highlight-colors.buffer_utils")
local colors = require("nvim-highlight-colors.color.utils")
local color_patterns = require("nvim-highlight-colors.color.patterns")
local ns_id = vim.api.nvim_create_namespace("nvim-highlight-colors")

local render_options = {
	first_column = "first_column",
	background = "background",
	foreground = "foreground"
}

local row_offset = 2
local windows = {}
local is_loaded = false
local options = {
	render = render_options.background,
	enable_named_colors = true,
	enable_tailwind = false,
	custom_colors = nil,
}

local M = {}

function M.is_window_already_created(row, value)
	for _, windows_data in ipairs(windows) do
		if windows_data.row == row and value == windows_data.color then
			return true
		end
	end

	return false
end

function M.close_windows()
	local ids = {}
	for _, window_data in ipairs(windows) do
		table.insert(ids, window_data.win_id)
	end
	utils.close_windows(ids)
	windows = {}
end

function M.clear_highlights()
	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, utils.get_last_row_index())
end

function M.close_not_visible_windows(min_row, max_row)
	local windows_to_remove = {}
	local new_windows_table = {}
	for _, window_data in ipairs(windows) do
		local window_config = vim.api.nvim_win_get_config(window_data.win_id)
		local window_bufpos = window_config.bufpos
		local window_row = window_bufpos[1] + row_offset
		local is_visible = window_row <= max_row and window_row >= min_row
		if is_visible == false then
			table.insert(windows_to_remove, window_data.win_id)
		else
			table.insert(new_windows_table, window_data)
		end
	end
	utils.close_windows(windows_to_remove)
	windows = new_windows_table
end

function M.show_visible_windows(min_row, max_row)
	local patterns = {
		color_patterns.hex_regex,
		color_patterns.hex_0x_regex,
		color_patterns.rgb_regex,
		color_patterns.hsl_regex,
		color_patterns.var_usage_regex,
	}

	if options.enable_named_colors then
		for _, css_color_pattern in pairs(colors.get_css_named_color_patterns()) do
			table.insert(patterns, css_color_pattern)
		end
	end

	if options.enable_tailwind then
		for _, tailwind_color_pattern in pairs(colors.get_tailwind_named_color_patterns()) do
			table.insert(patterns, tailwind_color_pattern)
		end
	end

	if (options.custom_colors ~= nil) then
		for _, custom_color in pairs(options.custom_colors) do 
			table.insert(patterns, custom_color.label)
		end
	end

	local positions = buffer_utils.get_positions_by_regex(patterns, min_row - 1, max_row, row_offset, options.render)

	for _, data in pairs(positions) do
		if options.render == render_options.foreground or options.render == render_options.background then
			utils.create_highlight(
				ns_id,
				data.row,
				data.start_column,
				data.end_column,
				data.value,
				options.render == render_options.foreground,
				options.custom_colors
			)
		elseif M.is_window_already_created(data.row, data.value) == false then
			table.insert(
				windows,
				{
					win_id = utils.create_window(data.row, 0, data.value, row_offset, options.custom_colors),
					row = data.row,
					color = data.value
				}
			)
		end
	end
end

function M.update_windows_visibility()
	local visible_rows = utils.get_win_visible_rows(0)
	local min_row = visible_rows[1]
	local max_row = visible_rows[2]

	M.show_visible_windows(min_row, max_row)
	M.close_not_visible_windows(min_row, max_row)
end

function M.turn_on()
	M.clear_highlights()
	M.close_windows()
	local visible_rows = utils.get_win_visible_rows(0)
	local min_row = visible_rows[1]
	local max_row = visible_rows[2]
	M.show_visible_windows(min_row, max_row)
	is_loaded = true
end

function M.turn_off()
	M.close_windows()
	M.clear_highlights()
	is_loaded = false
end

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

function M.toggle()
	if is_loaded then
		M.turn_off()
	else
		M.turn_on()
	end
end

vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP", "VimResized"}, {
	callback = function ()
		if is_loaded then
			M.turn_on()
		end
	end,
})

vim.api.nvim_create_autocmd({"WinScrolled"}, {
	callback = function()
		if is_loaded then
			M.update_windows_visibility()
		end
	end
})

vim.api.nvim_create_autocmd({"BufEnter"}, {
	callback = function ()
		if is_loaded then
			M.turn_on()
		end
	end,
})

vim.api.nvim_create_user_command("ColorHighlight",
function(opts)
	local arg = string.lower(opts.fargs[1])
	if arg == "on" then
		M.turnOn()
	elseif arg == "off" then
		M.turnOff()
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
})

return {
	turnOff = M.turn_off,
	turnOn = M.turn_on,
	setup = M.setup,
	toggle = M.toggle,
}
