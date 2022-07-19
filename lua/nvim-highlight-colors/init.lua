local utils = require("nvim-highlight-colors.utils")
local row_offset = 2
local windows = {}

function close_windows()
	local ids = {}
	for index, window_data in ipairs(windows) do
		table.insert(ids, window_data.win_id)
	end
	utils.close_windows(ids)
	windows = {}
end

function close_not_visible_windows(min_row, max_row)
	for index, window_data in ipairs(windows) do
		local window_config = vim.api.nvim_win_get_config(window_data.win_id)
		local window_bufpos = window_config.bufpos
		local window_row = window_bufpos[1] + row_offset
		local is_visible = window_row <= max_row and window_row >= min_row
		--print("win_row" .. window_row .. "--min_row-" .. min_row .. "--max_row-" .. max_row .. "--is_visible-" .. tostring(is_visible))
		if is_visible == false then
			utils.close_windows({window_data.win_id})
			table.remove(windows, index)
		end
	end
end

function show_visible_windows(min_row, max_row)
	local positions = utils.get_positions_by_regex("#[%a%d]+", min_row, max_row, row_offset)
	for index, data in pairs(positions) do
		local is_already_on_screen = false
		for index, windows_data in ipairs(windows) do
			if windows_data.row == data.row and data.value == windows_data.color then
				is_already_on_screen = true
			end
		end
		if is_already_on_screen == false then
			table.insert(
				windows,
				{
					win_id = utils.create_window(data.row, 0, data.value),
					row = data.row,
					color = data.value
				}
			)
		end
	end
end

function update_windows_visibility()
	local visible_rows = utils.get_win_visible_rows(0)
	local min_row = visible_rows[1]
	local max_row = visible_rows[2]

	show_visible_windows(min_row, max_row)
	close_not_visible_windows(min_row, max_row)
end

function turn_on()
	close_windows()
	local visible_rows = utils.get_win_visible_rows(0)
	local min_row = visible_rows[1]
	local max_row = visible_rows[2]
	show_visible_windows(min_row, max_row)
end

function turn_off()
	close_windows()
end

vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP", "VimResized"}, {
	callback = turn_on,
})

vim.api.nvim_create_autocmd({"WinScrolled"}, {
	callback = update_windows_visibility,
})

local M = {}

M.turnOff = turn_off
M.turnOn = turn_on

return M
