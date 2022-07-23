local M = {}

M.rgb_regex = "rgba?[(]+" .. string.rep("%s*%d+%s*", 3, ",") ..",?%s*%d*%.?%d*%s*[)]+"
M.hex_regex = "#[%a%d]+[%a%d]+[%a%d]+"

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

return M
