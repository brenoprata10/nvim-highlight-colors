local buffer_utils = require("nvim-highlight-colors.buffer_utils")
local table_utils  = require("nvim-highlight-colors.table_utils")

local M = {}

M.rgb_regex = "rgba?[(]+" .. string.rep("%s*%d+%s*", 3, "[,%s]") .. "[,%s/]?%s*%d*%.?%d*%s*[)]+"
M.hex_regex = "#[%a%d]+[%a%d]+[%a%d]+"
M.var_regex = "%-%-[%d%a-_]+"
M.var_declaration_regex = M.var_regex .. ":%s*" .. M.hex_regex
M.var_usage_regex = "var%(" .. M.var_regex .. "%)"

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

	if (M.is_var_color(color)) then
		local var_name = string.match(color, M.var_regex)
		local var_name_regex = string.gsub(var_name, "%-", "%%-")
		local var_position = buffer_utils.get_positions_by_regex(
			{
				var_name_regex .. ":%s*" .. M.hex_regex,
				var_name_regex .. ":%s*" .. M.rgb_regex
			},
			0,
			vim.fn.line('$'),
			row_offset
		)
		if (#var_position > 0) then
			local hex_color = string.match(var_position[1].value, M.hex_regex)
			local rgb_color = string.match(var_position[1].value, M.rgb_regex)
			return hex_color and M.get_color_value(hex_color) or M.get_color_value(rgb_color)
		end
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
	return string.len(color) == 4
end

function M.is_alpha_layer_hex(color)
	return string.match(color, M.hex_regex) ~= nil and string.len(color) == 9
end

function M.is_rgb_color(color)
	return string.match(color, M.rgb_regex)
end

function M.is_var_color(color)
	return string.match(color, M.var_usage_regex)
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

return M
