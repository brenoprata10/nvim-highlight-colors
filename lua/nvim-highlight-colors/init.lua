function turnOff()
	local test = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	print(test)
end

local M = {}

M.turnOff = turnOff

return M
