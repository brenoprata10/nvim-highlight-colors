local M = {}

M.color_usage_regex = "[:=]+%s*"

function M.get_buffer_contents(min_row, max_row)
	return vim.api.nvim_buf_get_lines(0, min_row, max_row, false)
end

function M.get_positions_by_regex(patterns, min_row, max_row, row_offset)
	local positions = {}
	local content = M.get_buffer_contents(min_row, max_row)

	for _, pattern in pairs(patterns) do
		for key, value in pairs(content) do
			for match in string.gmatch(value, pattern) do
				local pattern_without_usage_regex = M.remove_color_usage_pattern(match)
				local start_column = vim.fn.match(value, pattern_without_usage_regex)
				local end_column = vim.fn.matchend(value, pattern_without_usage_regex)
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

function M.remove_color_usage_pattern(match)
	local _, end_index = string.find(match, M.color_usage_regex)
	return end_index
		and string.sub(match, end_index + 1, string.len(match))
		or match
end

return M
