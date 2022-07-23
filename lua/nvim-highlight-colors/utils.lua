local colors = require("nvim-highlight-colors.colors")

local M = {}

function M.get_buffer_contents(min_row, max_row)
	return vim.api.nvim_buf_get_lines(0, min_row, max_row, false)
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

function M.get_positions_by_regex(patterns, min_row, max_row, row_offset)
	local positions = {}
	local content = M.get_buffer_contents(min_row, max_row)

	for _, pattern in pairs(patterns) do
		for key, value in pairs(content) do
			for match in string.gmatch(value, pattern) do
				local start_column = vim.fn.match(value, match)
				local end_column = vim.fn.matchend(value, match)
				local row = key + min_row - row_offset
				if (row >= 0) then
					table.insert(positions, {
						value = match,
						row = row,
						start_column = start_column,
						end_column = end_column
					})
				end
			end
		end
	end

	return positions
end

function M.create_window(row, col, bg_color)
	local highlight_color_name = string.gsub(bg_color, "#", ""):gsub("[(),%s%.]+", "")
	local buf = vim.api.nvim_create_buf(false, true)
	local window = vim.api.nvim_open_win(buf, false, {
		relative = "win",
		bufpos={row, col},
		width = 1,
		height = 1,
		focusable = false,
		noautocmd = true,
		zindex = 1,
		style= "minimal"
	})
	vim.api.nvim_command("highlight " .. highlight_color_name .. " guibg=" .. colors.get_color_value(bg_color))
	vim.api.nvim_win_set_option(
		window,
		'winhighlight',
		'Normal:' .. highlight_color_name .. ',FloatBorder:' .. highlight_color_name
	)

	local row_content = M.get_buffer_contents(row + 1, row + 2)
	vim.api.nvim_buf_set_lines(buf, 0, 0, true, {string.sub(row_content[1], 0, 1)})

	return window
end


function M.close_windows (windows)
	for index, data in pairs(windows) do
		if vim.api.nvim_win_is_valid(data) then
			vim.api.nvim_win_close(data, false)
		end
	end
end

return M
