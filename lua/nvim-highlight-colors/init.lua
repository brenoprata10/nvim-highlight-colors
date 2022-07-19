local utils = require("nvim-highlight-colors.utils")
local windows = {}
local hidden_windows = {}

function close_windows()
	utils.close_windows(windows)
	windows = {}
end

function update_visible_windows()
	local visible_rows = utils.get_win_visible_rows(0)
	local min_row = visible_rows[1]
	local max_row = visible_rows[2]

	for index, win_id in ipairs(windows) do
		local window_config = vim.api.nvim_win_get_config(win_id)
		local window_bufpos = window_config.bufpos
		local window_row = window_bufpos[1]
		local is_visible = window_row <= max_row and window_row >= min_row
		if is_visible == false then
			utils.close_windows({win_id})
			table.remove(windows, index)
			table.insert(hidden_windows, win_id)
		end
	end
end

function turn_on()
	close_windows()
	local positions = utils.get_positions_by_regex("#[%a%d]+")
	for index, data in pairs(positions) do
		table.insert(windows, utils.create_window(data.row, 0, data.value))
	end
end

function turn_off()
	close_windows()
end

vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP", "VimResized"}, {
	callback = turn_on,
})

vim.api.nvim_create_autocmd({"WinScrolled"}, {
	callback = update_visible_windows,
})

local M = {}

M.turnOff = turn_off
M.turnOn = turn_on

return M
