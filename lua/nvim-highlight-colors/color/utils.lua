local buffer_utils = require("nvim-highlight-colors.buffer_utils")
local css_named_colors = require("nvim-highlight-colors.named-colors.css")
local tailwind_named_colors = require("nvim-highlight-colors.named-colors.tailwind")
local converters = require("nvim-highlight-colors.color.converters")
local patterns = require("nvim-highlight-colors.color.patterns")

local M = {}

function M.get_color_value(color, row_offset, custom_colors)
	if patterns.is_short_hex_color(color) then
		return converters.short_hex_to_hex(color)
	end

	if patterns.is_alpha_layer_hex(color) then
		return string.sub(color, 1, 7)
	end

	if patterns.is_rgb_color(color) then
		local rgb_table = M.get_rgb_values(color)
		if #rgb_table >= 3 then
			return converters.rgb_to_hex(rgb_table[1], rgb_table[2], rgb_table[3])
		end
	end

	if patterns.is_hsl_color(color) then
		local hsl_table = M.get_hsl_values(color)
		local rgb_table = converters.hsl_to_rgb(hsl_table[1], hsl_table[2], hsl_table[3])
		return converters.rgb_to_hex(rgb_table[1], rgb_table[2], rgb_table[3])
	end

	if patterns.is_named_color(M.get_css_named_color_patterns(), color) then
		return M.get_css_named_color_value(color)
	end

	if patterns.is_named_color(M.get_tailwind_named_color_patterns(), color) then
		return M.get_tailwind_named_color_value(color)
	end

	if patterns.is_var_color(color) then
		return M.get_css_var_color(color, row_offset)
	end

	if custom_colors ~= nil and patterns.is_custom_color(color, custom_colors) then
		return M.get_custom_color(color, custom_colors)
	end

	return color:gsub("0x", "#")
end

function M.get_rgb_values(color)
	local rgb_table = {}
	for color_number in string.gmatch(color, "%d+") do
		table.insert(rgb_table, color_number)
	end

	return rgb_table
end

function M.get_hsl_values(color)
	local hsl_table = {}
	for color_number in string.gmatch(color, "%d?%.?%d+") do
		table.insert(hsl_table, color_number)
	end

	return hsl_table
end

function M.get_css_named_color_value(color)
	local color_name = string.match(color, "%a+")
	return css_named_colors[color_name]
end

function M.get_tailwind_named_color_value(color)
	local tailwind_color_name = color
	-- Removing tailwind prefix from color name: text-slate-500 -> slate-500
	local _, end_index = string.find(tailwind_color_name, patterns.tailwind_prefix .. "%-")
	if end_index then
		tailwind_color_name = string.sub(tailwind_color_name, end_index + 1, string.len(tailwind_color_name))
	end
	local tailwind_color = tailwind_named_colors[tailwind_color_name]
	if tailwind_color == nil then
		return nil
	end
	local rgb_table = M.get_rgb_values(tailwind_color)
	if #rgb_table >= 3 then
		return converters.rgb_to_hex(rgb_table[1], rgb_table[2], rgb_table[3])
	end
end

function M.get_tailwind_named_color_patterns()
	local tailwind_pattern = {}
	table.insert(tailwind_pattern, patterns.tailwind_prefix .. "%-%a+[%-%d+]*")

	return tailwind_pattern
end

function M.get_css_named_color_patterns()
	local css_pattern = {}
	table.insert(css_pattern, buffer_utils.color_usage_regex .. "%a+")

	return css_pattern
end

function M.get_custom_color(color, custom_colors)
	for _, custom_color in pairs(custom_colors) do
		-- Use string.match with the actual pattern from custom_color.label
		if string.match(color, "^" .. custom_color.label .. "$") then
			return M.get_color_value(custom_color.color)
		end
	end
	return nil
end

function M.get_css_var_color(color, row_offset)
	local var_name = string.match(color, patterns.var_regex)
	local var_name_regex = string.gsub(var_name, "%-", "%%-")
	local value_patterns = { patterns.hex_regex, patterns.rgb_regex, patterns.hsl_regex }
	local var_patterns = {}

	for _, pattern in pairs(value_patterns) do
		table.insert(var_patterns, var_name_regex .. ":%s*" .. pattern)
	end
	for _, css_color_pattern in pairs(M.get_css_named_color_patterns()) do
		table.insert(var_patterns, css_color_pattern)
	end

	local var_position = buffer_utils.get_positions_by_regex(var_patterns, 0, vim.fn.line("$"), row_offset)

	if #var_position > 0 then
		local hex_color = string.match(var_position[1].value, patterns.hex_regex)
		local rgb_color = string.match(var_position[1].value, patterns.rgb_regex)
		local hsl_color = string.match(var_position[1].value, patterns.hsl_regex)
		if hex_color then
			return M.get_color_value(hex_color)
		elseif rgb_color then
			return M.get_color_value(rgb_color)
		elseif hsl_color then
			return M.get_color_value(hsl_color)
		else
			return M.get_css_named_color_value(var_position[1].value)
		end
	end

	return color
end

function M.get_foreground_color_from_hex_color(color)
	local rgb_table = converters.hex_to_rgb(color)

	if rgb_table == nil or #rgb_table < 3 then
		return nil
	end

	-- see: https://stackoverflow.com/a/3943023/16807083
	rgb_table = vim.tbl_map(function(value)
		value = value / 255

		if value <= 0.04045 then
			return value / 12.92
		end

		return ((value + 0.055) / 1.055) ^ 2.4
	end, rgb_table)

	local luminance = (0.2126 * rgb_table[1]) + (0.7152 * rgb_table[2]) + (0.0722 * rgb_table[3])

	return luminance > 0.179 and "#000000" or "#ffffff"
end

return M
