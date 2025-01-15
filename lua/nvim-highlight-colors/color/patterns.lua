local M = {}

M.rgb_regex = "rgba?[(]+" .. string.rep("%s*%d+%s*", 3, "[,%s]") .. "[,%s/]?%s*%d*%.?%d*%%?%s*[)]+"
M.hex_regex = "#%x%x%x+%f[^%w_]"
M.hex_0x_regex = "%f[%w_]0x%x%x%x+%f[^%w_]"
M.hsl_regex = "hsla?[(]+" .. string.rep("%s*%d?%.?%d+%%?d?e?g?t?u?r?n?%s*", 3, "[,%s]") .. "[%s,/]?%s*%d*%.?%d*%%?%s*[)]+"
M.hsl_without_func_regex = ":%s*%d+%.?%d*%s+%d+%.?%d*%%%s+%d+%.?%d*%%"

M.var_regex = "%-%-[%d%a-_]+"
M.var_declaration_regex = M.var_regex .. ":%s*" .. M.hex_regex
M.var_usage_regex = "var%(" .. M.var_regex .. "%)"

M.tailwind_prefix = "!?%a+"

---Checks whether a color is short hex
---@return boolean
function M.is_short_hex_color(color)
	return string.match(color, M.hex_regex) and string.len(color) == 4
end

---Checks whether a color is hex
---@return boolean
function M.is_hex_color(color)
	return string.match(color, M.hex_regex) and string.len(color) == 7
end

---Checks whether a color is hex with alpha data
---@return boolean
function M.is_alpha_layer_hex(color)
	return string.match(color, M.hex_regex) ~= nil and string.len(color) == 9
end

---Checks whether a color is rgb
---@return boolean
function M.is_rgb_color(color)
	return string.match(color, M.rgb_regex)
end

---Checks whether a color is hsl
---@return boolean
function M.is_hsl_color(color)
	return string.match(color, M.hsl_regex)
end

-- Checks wether a color is a hsl without function color
---@return boolean
function M.is_hsl_without_func_color(color)
	return string.match(color, M.hsl_without_func_regex)
end

---Checks whether a color is a CSS var color
---@return boolean
function M.is_var_color(color)
	return string.match(color, M.var_usage_regex)
end

---Checks whether a color is a custom color
---@return boolean
function M.is_custom_color(color, custom_colors)
	for _, custom_color in pairs(custom_colors) do
		if color == custom_color.label:gsub("%%", "") then
			return true
		end
	end

	return false
end

---Checks whether a color is a named color e.g. 'blue', 'green'
---@return boolean
function M.is_named_color(named_color_patterns, color)
	for _, pattern in pairs(named_color_patterns) do
		if string.match(color, pattern) then
			return true
		end
	end

	return false
end

return M
