local buffer_utils = require("nvim-highlight-colors.buffer_utils")
local css_named_colors = require("nvim-highlight-colors.named-colors.css_named_colors")
local tailwind_named_colors = require("nvim-highlight-colors.named-colors.tailwind_named_colors")

local M = {}

M.rgb_regex = "rgba?[(]+" .. string.rep("%s*%d+%s*", 3, "[,%s]") .. "[,%s/]?%s*%d*%.?%d*%s*[)]+"
M.hex_regex = "#[%a%d]+[%a%d]+[%a%d]+"
M.hsl_regex = "hsla?[(]+" .. string.rep("%s*%d?%.?%d+%%?d?e?g?t?u?r?n?%s*", 3, "[,%s]") .. "[%s,/]?%s*%d*%.?%d*%%?%s*[)]+"

M.var_regex = "%-%-[%d%a-_]+"
M.var_declaration_regex = M.var_regex .. ":%s*" .. M.hex_regex
M.var_usage_regex = "var%(" .. M.var_regex .. "%)"

--M.tailwind_prefix_table = {"decoration", "text", "bg", "border", "divide", "outline", "ring", "ring-offset", "shadow"}
M.tailwind_prefix_table = {"%a+"}

function M.get_color_value(color, row_offset)
	if (M.is_short_hex_color(color)) then
		return M.convert_short_hex_to_hex(color)
	end

	if (M.is_alpha_layer_hex(color)) then
		return string.sub(color, 1, 7)
	end

	if (M.is_rgb_color(color)) then
		local rgb_table = M.get_rgb_values(color)
		if (#rgb_table >= 3) then
			return M.convert_rgb_to_hex(rgb_table[1], rgb_table[2], rgb_table[3])
		end
	end

	if (M.is_hsl_color(color)) then
		local hsl_table = M.get_hsl_values(color)
		local rgb_table = M.convert_hsl_to_rgb(hsl_table[1], hsl_table[2], hsl_table[3])
		return M.convert_rgb_to_hex(rgb_table[1], rgb_table[2], rgb_table[3])
	end

	if (M.is_named_color(M.get_css_named_color_patterns(), color)) then
		return M.get_css_named_color_value(color)
	end

	if (M.is_named_color(M.get_tailwind_named_color_patterns(), color)) then
		return M.get_tailwind_named_color_value(color)
	end

	if (M.is_var_color(color)) then
		return M.get_css_var_color(color, row_offset)
	end

	return color
end

function M.convert_rgb_to_hex(r, g, b)
 	return string.format("#%02X%02X%02X", r, g, b)
end

function M.convert_hex_to_rgb(hex)
	if M.is_short_hex_color(hex) then
		hex = M.convert_short_hex_to_hex(hex)
	end

	hex = hex:gsub("#", "")

	local r = tonumber("0x" .. hex:sub(1, 2))
	local g = tonumber("0x" .. hex:sub(3, 4))
	local b = tonumber("0x" .. hex:sub(5, 6))

	return r ~= nil and g ~= nil and b ~= nil and {r, g, b} or nil
end

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

function M.is_named_color(named_color_patterns, color)
	for _, pattern in pairs(named_color_patterns) do
		if string.match(color, pattern) then
			return true
		end
	end
	return false
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
	for _, prefix in pairs(M.tailwind_prefix_table) do
		local _, end_index = string.find(tailwind_color_name, prefix .. "%-")
		if end_index then
			tailwind_color_name = string.sub(tailwind_color_name, end_index + 1, string.len(tailwind_color_name))
		end
	end
	local tailwind_color = tailwind_named_colors[tailwind_color_name]
	local rgb_table = M.get_rgb_values(tailwind_color)
	if (#rgb_table >= 3) then
		return M.convert_rgb_to_hex(rgb_table[1], rgb_table[2], rgb_table[3])
	end
end

function M.get_tailwind_named_color_patterns()
	local patterns = {}
	for color_name in pairs(tailwind_named_colors) do
		for _, prefix in pairs(M.tailwind_prefix_table) do
			table.insert(patterns, prefix .. "%-" .. string.gsub(color_name, "%-", "%%-"))
		end
	end

	return patterns

end

function M.get_css_named_color_patterns()
	local patterns = {}
	for color_name in pairs(css_named_colors) do
		table.insert(
			patterns,
			buffer_utils.color_usage_regex .. color_name
		)
	end

	return patterns
end

function M.get_css_var_color(color, row_offset)
	local var_name = string.match(color, M.var_regex)
	local var_name_regex = string.gsub(var_name, "%-", "%%-")
	local value_patterns = {M.hex_regex, M.rgb_regex, M.hsl_regex}
	local var_patterns = {}

	for _, pattern in pairs(value_patterns) do
		table.insert(var_patterns, var_name_regex .. ":%s*" .. pattern)
	end
	for _, css_color_pattern in pairs(M.get_css_named_color_patterns()) do
		table.insert(var_patterns, css_color_pattern)
	end

	local var_position = buffer_utils.get_positions_by_regex(var_patterns, 0, vim.fn.line('$'), row_offset)

	if (#var_position > 0) then
		local hex_color = string.match(var_position[1].value, M.hex_regex)
		local rgb_color = string.match(var_position[1].value, M.rgb_regex)
		local hsl_color = string.match(var_position[1].value, M.hsl_regex)
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
	local rgb_table = M.convert_hex_to_rgb(color)

	if rgb_table == nil or #rgb_table < 3 then
		return nil
	end

	-- see: https://stackoverflow.com/a/3943023/16807083
	rgb_table = vim.tbl_map(
		function(value)
			value = value / 255

			if value <= 0.04045 then
				return value / 12.92
			end

			return ((value + 0.055) / 1.055) ^ 2.4
		end,
		rgb_table
	)

	local luminance = (0.2126 * rgb_table[1]) + (0.7152 * rgb_table[2]) + (0.0722 * rgb_table[3])

	return luminance > 0.179 and "#000000" or "#ffffff"
end

-- Function retrieved from this stackoverflow post:
-- https://stackoverflow.com/questions/68317097/how-to-properly-convert-hsl-colors-to-rgb-colors-in-lua
function M.convert_hsl_to_rgb(h, s, l)
    h = h / 360
    s = s / 100
    l = l / 100

    local r, g, b;

    if s == 0 then
        r, g, b = l, l, l; -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p;
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s;
        local p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    end

    if not a then a = 1 end
    return {r * 255, g * 255, b * 255, a * 255}
end


return M
