local patterns = require("nvim-highlight-colors.color.patterns")

local M = {}

---Converts a rgb color to hex
---@param r string
---@param g string
---@param b string
---@return string
function M.rgb_to_hex(r, g, b)
 	return string.format("#%02X%02X%02X", r, g, b)
end

---Converts a hex color to rgb
---@param hex string
---@return {r: number, g: number, b: number}|nil
function M.hex_to_rgb(hex)
	if patterns.is_short_hex_color(hex) then
		hex = M.short_hex_to_hex(hex)
	end

	hex = hex:gsub("#", "")

	local r = tonumber("0x" .. hex:sub(1, 2))
	local g = tonumber("0x" .. hex:sub(3, 4))
	local b = tonumber("0x" .. hex:sub(5, 6))

	return r ~= nil and g ~= nil and b ~= nil and {r, g, b} or nil
end

---Converts a short hex color to hex
---@param color string
---@return string
function M.short_hex_to_hex(color)
	local new_color = "#"
	for char in color:gmatch"." do
		if (char ~= '#') then
			new_color = new_color .. char:rep(2)
		end
	end

	return new_color
end

local a

---Converts a hsl color to rgb
---@param h string
---@param s string
---@param l string
---@return {r: number, g: number, b: number, a: number}
-- Function retrieved from this stackoverflow post:
-- https://stackoverflow.com/questions/68317097/how-to-properly-convert-hsl-colors-to-rgb-colors-in-lua
function M.hsl_to_rgb(h, s, l)
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
