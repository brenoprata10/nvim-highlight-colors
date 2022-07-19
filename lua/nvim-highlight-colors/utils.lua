local M = {}

function M.get_buffer_contents(minRow, maxRow)
	return vim.api.nvim_buf_get_lines(0, minRow, maxRow, false)
end

function M.get_win_visible_rows(winid)
	return vim.api.nvim_win_call(
		winid,
		function()
			return {
				vim.fn.line('w0'),
				vim.fn.line('w$')
			}
		end
	)
end

function M.get_positions_by_regex(pattern, minRow, maxRow, row_offset)
	local positions = {}
	local content = M.get_buffer_contents(minRow, maxRow)

	for key, value in pairs(content) do
		for match in string.gmatch(value, pattern) do
			local startColumn = vim.fn.match(value, match)
			local endColumn = vim.fn.matchend(value, match)
			table.insert(positions, {
				value = match,
				row = key + minRow - row_offset,
				startColumn = startColumn,
				endColumn = endColumn
			})
		end
	end

	return positions
end

function M.create_window(row, col, bg_color)
	local highlightColorName = string.gsub(bg_color, "#", "")
	local buf = vim.api.nvim_create_buf(false, true)
	local window = vim.api.nvim_open_win(buf, false, {
		relative = "win",
		bufpos={row, col},
		width = 1,
		height = 1,
		focusable = false,
		noautocmd = true,
		zindex = 1,
	})
	vim.api.nvim_command("highlight " .. highlightColorName .. " guibg=" .. bg_color)
	vim.api.nvim_win_set_option(window, 'winhighlight', 'Normal:' .. highlightColorName .. ',FloatBorder:' .. highlightColorName)
	return window
end


function M.close_windows (windows)
	for index, data in pairs(windows) do
		vim.api.nvim_win_close(data, true)
	end
end

return M
