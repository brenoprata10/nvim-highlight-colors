local utils = require("nvim-highlight-colors.utils")

function turn_on()
	local positions = utils.get_positions_by_regex("asd")
	for index, data in ipairs(positions) do
		utils.create_window(data.row, data.startColumn, "yellow")
	end
end

function turn_off()
end

local M = {}

M.turnOff = turn_off
M.turnOn = turn_on

return M
