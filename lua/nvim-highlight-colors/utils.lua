local M = {}

function M.getBufferContents()
	local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	print(table.concat(content, "\n"))
end

function M.createWindow(col, row)
	local buf = vim.api.nvim_create_buf(false, true)
	local window = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		col = col,
		row = row,
		width = 1,
		height = 1,
		focusable = false
	})
	vim.api.nvim_command("highlight MyHighlight guibg=RED")
	vim.api.nvim_win_set_option(window, 'winhighlight', 'Normal:MyHighlight,FloatBorder:MyHighlight')
end

return M
