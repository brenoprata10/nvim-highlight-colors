local utils = require("nvim-highlight-colors.utils")

function turnOn()
	utils.createWindow(10, 10)
end

local M = {}

M.turnOff = utils.getBufferContents
M.turnOn = turnOn

return M
