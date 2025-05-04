local patterns = require('nvim-highlight-colors.color.patterns')

local M = {}

---Converts a rgb color to hex
---@param r string
---@param g string
---@param b string
---@usage rgb_to_hex(255, 255, 255) => Returns '#FFFFFF'
---@return string
function M.rgb_to_hex(r, g, b)
  return string.format('#%02X%02X%02X', r, g, b)
end

---Converts a hex color to rgb
---@param hex string
---@usage hex_to_rgb("#FFFFFF") => Returns {255, 255, 255}
---@return {r: number, g: number, b: number}|nil
function M.hex_to_rgb(hex)
  if patterns.is_short_hex_color(hex) then
    hex = M.short_hex_to_hex(hex)
  end

  hex = hex:gsub('#', '')

  local r = tonumber('0x' .. hex:sub(1, 2))
  local g = tonumber('0x' .. hex:sub(3, 4))
  local b = tonumber('0x' .. hex:sub(5, 6))

  return r ~= nil and g ~= nil and b ~= nil and { r, g, b } or nil
end

---Converts a short hex color to hex
---@param color string
---@usage short_hex_to_hex("#FFF") => Returns "#FFFFFF"
---@return string
function M.short_hex_to_hex(color)
  local new_color = '#'
  for char in color:gmatch('.') do
    if char ~= '#' then
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

  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local function hue2rgb(p, q, t)
      if t < 0 then
        t = t + 1
      end
      if t > 1 then
        t = t - 1
      end
      if t < 1 / 6 then
        return p + (q - p) * 6 * t
      end
      if t < 1 / 2 then
        return q
      end
      if t < 2 / 3 then
        return p + (q - p) * (2 / 3 - t) * 6
      end
      return p
    end

    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue2rgb(p, q, h + 1 / 3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1 / 3)
  end

  if not a then
    a = 1
  end
  return {
    math.floor(r * 255),
    math.floor(g * 255),
    math.floor(b * 255),
    math.floor(a * 255),
  }
end

---Converts an oklch color to rgb
---@param l string Lightness (0-1 or 0-100%)
---@param c string Chroma (0-0.4 typically)
---@param h string Hue (0-360deg)
---@usage oklch_to_rgb(0.4, 0.268, 34.8) => Returns {r, g, b}
---@return {r: number, g: number, b: number, a: number}
function M.oklch_to_rgb(l, c, h)
  -- Normalize input values
  if l > 1 then
    l = l / 100
  end -- Convert from percentage if needed

  -- Convert OKLCH to Oklab
  local hrad = math.rad(tonumber(h) or 0)
  local a = c * math.cos(hrad)
  local b = c * math.sin(hrad)

  -- Convert Oklab to linear RGB
  -- These matrices are from the OKLCH specification
  local l_ = l + 0.3963377774 * a + 0.2158037573 * b
  local m_ = l - 0.1055613458 * a - 0.0638541728 * b
  local s_ = l - 0.0894841775 * a - 1.2914855480 * b

  local l_cubed = l_ * l_ * l_
  local m_cubed = m_ * m_ * m_
  local s_cubed = s_ * s_ * s_

  -- Linear RGB to sRGB
  local r_linear = 4.0767416621 * l_cubed - 3.3077115913 * m_cubed + 0.2309699292 * s_cubed
  local g_linear = -1.2684380046 * l_cubed + 2.6097574011 * m_cubed - 0.3413193965 * s_cubed
  local b_linear = -0.0041960863 * l_cubed - 0.7034186147 * m_cubed + 1.7076147010 * s_cubed

  -- Apply gamma correction and clamp to 0-255
  local r = math.max(0, math.min(255, math.floor(255 * srgb_transfer(r_linear))))
  local g = math.max(0, math.min(255, math.floor(255 * srgb_transfer(g_linear))))
  local b = math.max(0, math.min(255, math.floor(255 * srgb_transfer(b_linear))))

  return { r, g, b, 255 }
end

-- Helper function for the sRGB transfer function
function srgb_transfer(x)
  if x <= 0 then
    return 0
  end
  if x >= 1 then
    return 1
  end
  if x < 0.0031308 then
    return 12.92 * x
  else
    return 1.055 * (x ^ (1 / 2.4)) - 0.055
  end
end

return M
