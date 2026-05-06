local patterns = require("nvim-highlight-colors.color.patterns")

local M = {}

---Converts a rgb color to hex
---@param r string
---@param g string
---@param b string
---@usage rgb_to_hex(255, 255, 255) => Returns '#FFFFFF'
---@return string
function M.rgb_to_hex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

---Converts a hex color to rgb
---@param hex string
---@usage hex_to_rgb("#FFFFFF") => Returns {255, 255, 255}
---@return {r: number, g: number, b: number}|nil
function M.hex_to_rgb(hex)
    if patterns.is_short_hex_color(hex) then
        hex = M.short_hex_to_hex(hex)
    end

    hex = hex:gsub("#", "")

    local r = tonumber("0x" .. hex:sub(1, 2))
    local g = tonumber("0x" .. hex:sub(3, 4))
    local b = tonumber("0x" .. hex:sub(5, 6))

    return r ~= nil and g ~= nil and b ~= nil and { r, g, b } or nil
end

---Converts a short hex color to hex
---@param color string
---@usage short_hex_to_hex("#FFF") => Returns "#FFFFFF"
---@return string
function M.short_hex_to_hex(color)
    local new_color = "#"
    for char in color:gmatch "." do
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
---@usage hsl_to_rgb(240, 100, 68) => Returns {91, 91, 255, 255}
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
    return {
        math.floor(r * 255),
        math.floor(g * 255),
        math.floor(b * 255),
        math.floor(a * 255)
    }
end

---@param l string
---@param c string
---@param h string
---@usage oklch_to_rgb(1, 0, 0) => Returns {255, 255, 255, 255}
---@return {r: number, g: number, b: number, a: number}
function M.oklch_to_rgb(l, c, h)
    l = math.min(math.max(tonumber(l), 0), 1)
    c = math.max(tonumber(c), 0)
    h = tonumber(h) % 360

    local hr = math.rad(h)
    local a_oklab = c * math.cos(hr)
    local b_oklab = c * math.sin(hr)

    -- OKLab to Linear RGB using the correct conversion matrix
    local L_ = l + 0.3963377774 * a_oklab + 0.2158037573 * b_oklab
    local M_ = l - 0.1055613458 * a_oklab - 0.0638541728 * b_oklab
    local S_ = l - 0.0894841775 * a_oklab - 1.2914855480 * b_oklab

    local L_cubed = L_ * L_ * L_
    local M_cubed = M_ * M_ * M_
    local S_cubed = S_ * S_ * S_

    local r_linear = 4.0767416621 * L_cubed - 3.3077115913 * M_cubed + 0.2309699292 * S_cubed
    local g_linear = -1.2684380046 * L_cubed + 2.6097574011 * M_cubed - 0.3413193965 * S_cubed
    local b_linear = -0.0041960863 * L_cubed - 0.7034186147 * M_cubed + 1.7076147010 * S_cubed

    local function lin_to_srgb(x)
        if x <= 0.0031308 then
            return 12.92 * x
        else
            return 1.055 * (x ^ (1 / 2.4)) - 0.055
        end
    end

    local function clamp(x)
        return math.min(math.max(x, 0), 1)
    end

    return {
        math.floor(clamp(lin_to_srgb(r_linear)) * 255),
        math.floor(clamp(lin_to_srgb(g_linear)) * 255),
        math.floor(clamp(lin_to_srgb(b_linear)) * 255),
        255 -- alpha
    }
end

---Converts an OKLCH color to RGB
---@param l string
---@param c string
---@param h string
---@usage oklch_to_rgb(1, 0, 0) => Returns {255, 255, 255, 255}
---@return {r: number, g: number, b: number, a: number}
function M.oklch_to_rgb(l, c, h)
	l = math.min(math.max(tonumber(l), 0), 1)
	c = math.max(tonumber(c), 0)
	h = tonumber(h) % 360

	local hr = math.rad(h)
	local a_oklab = c * math.cos(hr)
	local b_oklab = c * math.sin(hr)

	-- OKLab to Linear RGB using the correct conversion matrix
	local L_ = l + 0.3963377774 * a_oklab + 0.2158037573 * b_oklab
	local M_ = l - 0.1055613458 * a_oklab - 0.0638541728 * b_oklab
	local S_ = l - 0.0894841775 * a_oklab - 1.2914855480 * b_oklab

	local L_cubed = L_ * L_ * L_
	local M_cubed = M_ * M_ * M_
	local S_cubed = S_ * S_ * S_

	local r_linear = 4.0767416621 * L_cubed - 3.3077115913 * M_cubed + 0.2309699292 * S_cubed
	local g_linear = -1.2684380046 * L_cubed + 2.6097574011 * M_cubed - 0.3413193965 * S_cubed
	local b_linear = -0.0041960863 * L_cubed - 0.7034186147 * M_cubed + 1.7076147010 * S_cubed

	local function lin_to_srgb(x)
		if x <= 0.0031308 then
			return 12.92 * x
		else
			return 1.055 * (x ^ (1 / 2.4)) - 0.055
		end
	end

	local function clamp(x)
		return math.min(math.max(x, 0), 1)
	end

	return {
		math.floor(clamp(lin_to_srgb(r_linear)) * 255),
		math.floor(clamp(lin_to_srgb(g_linear)) * 255),
		math.floor(clamp(lin_to_srgb(b_linear)) * 255),
		255 -- alpha
	}
end

return M
