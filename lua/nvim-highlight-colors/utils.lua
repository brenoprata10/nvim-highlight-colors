local M = {}

M.rgb_regex = "rgba?[(]+" .. string.rep("%s*%d+%s*", 3, ",") ..",?%s*%d*%.?%d*%s*[)]+"

function M.get_color_value(color)
	if (M.is_short_hex_color(color)) then
		return M.convert_short_hex_to_hex(color)
	end

	if (M.is_rgb_color(color)) then
		local rgb_table = {}
		local count = 1
		for color_number in string.gmatch(color, "%d+") do
			rgb_table[count] = color_number
			count = count + 1
		end
		if (count >= 4) then
			return M.convert_rgb_to_hex(rgb_table[1], rgb_table[2], rgb_table[3])
		end
	end

	return color
end

function M.convert_rgb_to_hex(r, g, b)
 	return string.format("#%02X%02X%02X", r, g, b)
end

function M.is_short_hex_color(color)
	return string.len(color) == 4
end

function M.is_rgb_color(color)
	return string.match(color, M.rgb_regex)
end

function M.convert_short_hex_to_hex(color)
	if (M.is_short_hex_color(color)) then
		local new_color = "#"
		for char in color:gmatch"." do
			if (char ~= '#') then
				new_color = new_color .. char:rep(2)
			end
		end
		return new_color
	end

	return color
end

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

	for key_pattern, pattern in pairs(patterns) do
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
	})
	vim.api.nvim_command("highlight " .. highlight_color_name .. " guibg=" .. M.get_color_value(bg_color))
	vim.api.nvim_win_set_option(window, 'winhighlight', 'Normal:' .. highlight_color_name .. ',FloatBorder:' .. highlight_color_name)
	return window
end


function M.close_windows (windows)
	for index, data in pairs(windows) do
		vim.api.nvim_win_close(data, true)
	end
end

return M
