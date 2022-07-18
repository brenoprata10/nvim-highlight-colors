local utils = require("nvim-highlight-colors.utils")

function turn_on()
	local positions = utils.get_positions_by_regex("#[%a%d]+")
	for index, data in ipairs(positions) do
		utils.create_window(data.row, 0, data.value)
	end
end

function turn_off()
end

local M = {}

M.turnOff = turn_off
M.turnOn = turn_on

return M
