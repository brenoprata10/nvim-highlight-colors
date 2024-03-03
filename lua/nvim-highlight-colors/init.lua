local utils = require("nvim-highlight-colors.utils")
local buffer_utils = require("nvim-highlight-colors.buffer_utils")
local colors = require("nvim-highlight-colors.color.utils")
local color_patterns = require("nvim-highlight-colors.color.patterns")
local ns_id = vim.api.nvim_create_namespace("nvim-highlight-colors")

if vim.g.loaded_nvim_highlight_colors ~= nil then
	return {}
end
vim.g.loaded_nvim_highlight_colors = 1

local render_options = utils.render_options
local row_offset = 2
local is_loaded = false
local options = {
	render = render_options.background,
	enable_named_colors = true,
	enable_tailwind = false,
	custom_colors = nil,
}

local M = {}

function M.setup(user_options)
	is_loaded = true
	if (user_options ~= nil and user_options ~= {}) then
		for key, _ in pairs(user_options) do
			if user_options[key] ~= nil then
				options[key] = user_options[key]
			end
		end
	end
end

function M.highlight_colors(min_row, max_row)
	local patterns = {
		color_patterns.hex_regex,
		color_patterns.hex_0x_regex,
		color_patterns.rgb_regex,
		color_patterns.hsl_regex,
		color_patterns.var_usage_regex,
	}

	if options.enable_named_colors then
	       table.insert(patterns, colors.get_css_named_color_pattern())
	end

	if options.enable_tailwind then
	       table.insert(patterns, colors.get_tailwind_named_color_pattern())
	end

	if (options.custom_colors ~= nil) then
		for _, custom_color in pairs(options.custom_colors) do
			table.insert(patterns, custom_color.label)
		end
	end

	local positions = buffer_utils.get_positions_by_regex(patterns, min_row - 1, max_row, row_offset)

	for _, data in pairs(positions) do
		utils.create_highlight(
			ns_id,
			data.row,
			data.start_column,
			data.end_column,
			data.value,
			options.render,
			options.custom_colors
		)
	end
end

function M.turn_on()
	M.clear_highlights()
	local visible_rows = utils.get_win_visible_rows(0)
	local min_row = visible_rows[1]
	local max_row = visible_rows[2]
	M.highlight_colors(min_row, max_row)
	is_loaded = true
end

function M.turn_off()
	M.clear_highlights()
	is_loaded = false
end

function M.clear_highlights()
	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, utils.get_last_row_index())
end

function M.toggle()
	if is_loaded then
		M.turn_off()
	else
		M.turn_on()
	end
end

vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP", "VimResized"}, {
	callback = function ()
		if is_loaded then
			M.turn_on()
		end
	end,
})

vim.api.nvim_create_autocmd({"WinScrolled"}, {
	callback = function()
		if is_loaded then
			local visible_rows = utils.get_win_visible_rows(0)
			local min_row = visible_rows[1]
			local max_row = visible_rows[2]

			M.highlight_colors(min_row, max_row)
		end
	end
})

vim.api.nvim_create_autocmd({"BufEnter"}, {
	callback = function ()
		if is_loaded then
			M.turn_on()
		end
	end,
})

vim.api.nvim_create_user_command("HighlightColors",
	function(opts)
		local arg = string.lower(opts.fargs[1])
		if arg == "on" then
			M.turn_on()
		elseif arg == "off" then
			M.turn_off()
		elseif arg == "toggle" then
			M.toggle()
		end
	end,
	{
		nargs = 1,
		complete = function()
			return { "On", "Off", "Toggle" }
		end,
		desc = "Config color highlight"
	}
)

utils.deprecate()

return {
	turnOff = M.turn_off,
	turnOn = M.turn_on,
	setup = M.setup,
	toggle = M.toggle,
}
