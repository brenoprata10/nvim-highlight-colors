local colors = require("nvim-highlight-colors.color.utils")
local buffer_utils = require("nvim-highlight-colors.buffer_utils")

local M = {}

function M.get_last_row_index()
	return vim.fn.line('$')
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

function create_highlight_name(color_value)
	return string.gsub(color_value, "#", ""):gsub("[(),%s%.-/%%=:]+", "")
end

function M.create_window(row, col, bg_color, row_offset)
	local highlight_color_name = create_highlight_name(bg_color)
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
	pcall(vim.api.nvim_set_hl, 0, highlight_color_name, {
        bg = colors.get_color_value(bg_color, row_offset)
    })
	vim.api.nvim_win_set_option(
		window,
		'winhighlight',
		'Normal:' .. highlight_color_name .. ',FloatBorder:' .. highlight_color_name
	)

	local row_content = buffer_utils.get_buffer_contents(row + 1, row + 2)
	vim.api.nvim_buf_set_lines(buf, 0, 0, true, {string.sub(row_content[1], 0, 1)})

	return window
end

function M.create_highlight(ns_id, row, start_column, end_column, color, should_colorize_foreground)
	local highlight_group = create_highlight_name(color)
	local color_value = colors.get_color_value(color, 2)
	if color_value == nil then
		return
	end

	if should_colorize_foreground then
		pcall(vim.api.nvim_set_hl, 0, highlight_group, {
            		fg = color_value
        	})
	else
		local foreground_color = colors.get_foreground_color_from_hex_color(color_value)
		pcall(vim.api.nvim_set_hl, 0, highlight_group, {
            		fg = foreground_color,
            		bg = color_value
        	})
	end
	vim.api.nvim_buf_add_highlight(
		0,
		ns_id,
		highlight_group,
		row + 1,
		start_column,
		end_column
	)
end

function M.close_windows (windows)
	for _, data in pairs(windows) do
		if vim.api.nvim_win_is_valid(data) then
			vim.api.nvim_win_close(data, false)
		end
	end
end

return M
