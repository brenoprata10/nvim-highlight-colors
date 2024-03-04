local table_utils = require "nvim-highlight-colors.table_utils"

local M = {}

M.color_usage_regex = "[:=]+%s*[\"']?"

function M.get_buffer_contents(min_row, max_row, active_buffer_id)
	return vim.api.nvim_buf_get_lines(active_buffer_id, min_row, max_row, false)
end

function M.get_positions_by_regex(patterns, min_row, max_row, active_buffer_id, row_offset)
	local positions = {}
	local content = M.get_buffer_contents(min_row, max_row, active_buffer_id)

	for _, pattern in pairs(patterns) do
		for key, value in pairs(content) do
			for match in string.gmatch(value, pattern) do
				local row = key + min_row - row_offset
				local column_offset = M.get_column_offset(positions, match, row)
				local pattern_without_usage_regex = M.remove_color_usage_pattern(match)
				local start_column = vim.fn.match(value, pattern_without_usage_regex, column_offset)
				local end_column = vim.fn.matchend(value, pattern_without_usage_regex, column_offset)

				table.insert(positions, {
					value = match,
					row = row,
					start_column = start_column,
					end_column = end_column
				})
			end
		end
	end

	return positions
end


-- Handles repeated colors in the same row: e.g. `#fff #fff`
-- This code will search if the color that is going to be added is already present in the same row in `positions` table
-- If the color already exists in the same row, it will set `column_offset` to the end_column of the previous color
-- With this logic we can control the offset of the regex when calling `vim.fn.match` 
-- Real case scenario:
--   1. Detects and adds the first color to `positions` table
--   2. Detects the second color in the same row
--   3. Sets column_offset based on the '↓' column
--         ↓ 
--      #fff #fff
--   4. Runs vim.fn.match with the column_offset on it. Avoids highlighting the same color again and leaving the second color without highlight
function M.get_column_offset(positions, match, row)
	local repeated_colors_in_row = table_utils.filter(
		positions,
		function(position)
			return position.value == match and position.row == row
		end
	)
	local last_repeated_color = repeated_colors_in_row[#repeated_colors_in_row]
	return last_repeated_color and last_repeated_color.end_column or nil
end

function M.remove_color_usage_pattern(match)
	local _, end_index = string.find(match, M.color_usage_regex)
	return end_index
		and string.sub(match, end_index + 1, string.len(match))
		or match
end

return M
