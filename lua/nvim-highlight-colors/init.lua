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

local load_on_start_up = false
local row_offset = 2
local windows = {}
local is_loaded = false
local options = {
	render = render_options.background,
	enable_named_colors = true,
	enable_tailwind = false
}

local H = {}

function H.is_window_already_created(row, value)
	for _, windows_data in ipairs(windows) do
		if windows_data.row == row and value == windows_data.color then
			return true
		end
	end

	return false
end

function H.close_windows()
	local ids = {}
	for _, window_data in ipairs(windows) do
		table.insert(ids, window_data.win_id)
	end
	utils.close_windows(ids)
	windows = {}
end

function H.clear_highlights()
	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, utils.get_last_row_index())
end

function H.close_not_visible_windows(min_row, max_row)
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

function H.show_visible_windows(min_row, max_row)
	local patterns = {
		color_patterns.hex_regex,
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

	local positions = buffer_utils.get_positions_by_regex(patterns, min_row - 1, max_row, row_offset, options.render)

	for _, data in pairs(positions) do
		if options.render == render_options.foreground or options.render == render_options.background then
			utils.create_highlight(
				ns_id,
				data.row,
				data.start_column,
				data.end_column,
				data.value,
				options.render == render_options.foreground
			)
		elseif H.is_window_already_created(data.row, data.value) == false then
			table.insert(
				windows,
				{
					win_id = utils.create_window(data.row, 0, data.value, row_offset),
					row = data.row,
					color = data.value
				}
			)
		end
	end
end

function H.update_windows_visibility()
	local visible_rows = utils.get_win_visible_rows(0)
	local min_row = visible_rows[1]
	local max_row = visible_rows[2]

	H.show_visible_windows(min_row, max_row)
	H.close_not_visible_windows(min_row, max_row)
end

function H.turn_on()
	H.clear_highlights()
	H.close_windows()
	local visible_rows = utils.get_win_visible_rows(0)
	local min_row = visible_rows[1]
	local max_row = visible_rows[2]
	H.show_visible_windows(min_row, max_row)
	is_loaded = true
end

function H.turn_off()
	H.close_windows()
	H.clear_highlights()
	is_loaded = false
end

function H.setup(user_options)
	load_on_start_up = true
	if (user_options ~= nil and user_options ~= {}) then
		for key, _ in pairs(options) do
			if user_options[key] ~= nil then
				options[key] = user_options[key]
			end
		end
	end
end

function H.toggle()
	if is_loaded then
		H.turn_off()
	else
		H.turn_on()
	end
end

vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP", "VimResized"}, {
	callback = function ()
		if not is_loaded then
			return
		end
		H.turn_on()
	end,
})

vim.api.nvim_create_autocmd({"WinScrolled"}, {
	callback = function()
		if not is_loaded then
			return
		end
		H.update_windows_visibility()
	end
})

vim.api.nvim_create_autocmd({"BufEnter"}, {
	callback = function ()
		if load_on_start_up == true then
			H.turn_on()
		end
	end,
})

return {
	turnOff = H.turn_off,
	turnOn = H.turn_on,
	setup = H.setup,
	toggle = H.toggle,
}
