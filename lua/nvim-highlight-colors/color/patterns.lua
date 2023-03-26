local M = {}

M.rgb_regex = "rgba?[(]+" .. string.rep("%s*%d+%s*", 3, "[,%s]") .. "[,%s/]?%s*%d*%.?%d*%s*[)]+"
M.hex_regex = "#[%a%d]+[%a%d]+[%a%d]+"
M.hex_0x_regex = "0x[%a%d]+[%a%d]+[%a%d]+"
M.hsl_regex = "hsla?[(]+" .. string.rep("%s*%d?%.?%d+%%?d?e?g?t?u?r?n?%s*", 3, "[,%s]") .. "[%s,/]?%s*%d*%.?%d*%%?%s*[)]+"

M.var_regex = "%-%-[%d%a-_]+"
M.var_declaration_regex = M.var_regex .. ":%s*" .. M.hex_regex
M.var_usage_regex = "var%(" .. M.var_regex .. "%)"

M.tailwind_prefix = "%a+"

function M.is_short_hex_color(color)
	return string.match(color, M.hex_regex) and string.len(color) == 4
end

function M.is_alpha_layer_hex(color)
	return string.match(color, M.hex_regex) ~= nil and string.len(color) == 9
end

function M.is_rgb_color(color)
	return string.match(color, M.rgb_regex)
end

function M.is_hsl_color(color)
	return string.match(color, M.hsl_regex)
end

function M.is_var_color(color)
	return string.match(color, M.var_usage_regex)
end

function M.is_custom_color(color, custom_colors)
	for _, custom_color in pairs(custom_colors) do
		if color == custom_color.label:gsub("%%", "") then
			return true
		end
	end

	return false
end

function M.is_named_color(named_color_patterns, color)
	for _, pattern in pairs(named_color_patterns) do
		if string.match(color, pattern) then
			return true
		end
	end

	return false
end

return M
