local M = {}

M.rgb_regex = 'rgba?[(]+' .. string.rep('%s*%d+%s*', 3, '[,%s]') .. '[,%s/]?%s*%d*%.?%d*%%?%s*[)]+'
M.hex_regex = '#%x%x%x+%f[^%w_]'
M.hex_0x_regex = '%f[%w_]0x%x%x%x+%f[^%w_]'
M.hsl_regex = 'hsla?[(]+'
  .. string.rep('%s*%d*%.?%d+%%?d?e?g?t?u?r?n?%s*', 3, '[,%s]')
  .. '[%s,/]?%s*%d*%.?%d*%%?%s*[)]+'
-- Matches: `: 0 69% 69%`
M.hsl_without_func_regex = ':' .. string.rep('%s*%d*%.?%d+%%?d?e?g?t?u?r?n?%s*', 3, '[,%s]')

M.oklch_regex = 'oklch%(+%s*%d*%.?%d+%%?%s*%s+%d*%.?%d+%%?%s*%s+%d*%.?%d+d?e?g?t?u?r?n?%s*[%s,/]?%s*%d*%.?%d*%%?%s*%)+'

M.var_regex = '%-%-[%d%a-_]+'
M.var_declaration_regex = M.var_regex .. ':%s*' .. M.hex_regex
M.var_usage_regex = 'var%(' .. M.var_regex .. '%)'

M.tailwind_prefix = '!?%a+'

M.ansi_regex = '\\033%[%d;%d%dm'

---Checks whether a color is short hex
---@param color string
---@usage is_short_hex_color("#FFF") => Returns true
---@return boolean
function M.is_short_hex_color(color)
  if string.match(color, M.hex_regex) then
    return string.len(color) == 4
  end
  return false
end

---Checks whether a color is hex
---@param color string
---@usage is_hex_color("#FFFFFF") => Returns true
---@return boolean
function M.is_hex_color(color)
  if string.match(color, M.hex_regex) then
    return string.len(color) == 7
  end
  return false
end

---Checks whether a color is hex with alpha data
---@param color string
---@usage is_alpha_layer_hex("#FFFFFFFF") => Returns true
---@return boolean
function M.is_alpha_layer_hex(color)
  return string.match(color, M.hex_regex) ~= nil and string.len(color) == 9
end

---Checks whether a color is rgb
---@param color string
---@usage is_rgb_color("rgb(255, 255, 255)") => Returns true
---@return boolean
function M.is_rgb_color(color)
  return string.match(color, M.rgb_regex) ~= nil
end

---Checks whether a color is hsl
---@param color string
---@usage is_hsl_color("hsl(240, 100%, 50%)") => Returns true
---@return boolean
function M.is_hsl_color(color)
  return string.match(color, M.hsl_regex) ~= nil
end

-- Checks wether a color is a hsl without function color
---@param color string
---@usage is_hsl_without_func_color(": 0 0% 100%;") => Returns true
---@return boolean
function M.is_hsl_without_func_color(color)
  return string.match(color, M.hsl_without_func_regex) ~= nil
end

---Checks whether a color is a CSS var color
---@param color string
---@usage is_var_color("var(--css-color)") => Returns true
---@return boolean
function M.is_var_color(color)
  return string.match(color, M.var_usage_regex) ~= nil
end

---Checks whether a color is a custom color
---@param color string
---@usage is_custom_color("custom-color", {{label = 'custom%-color', color = '#FFFFFF'}}) => Returns true
---@return boolean
function M.is_custom_color(color, custom_colors)
  for _, custom_color in pairs(custom_colors) do
    if color == custom_color.label:gsub('%%', '') then
      return true
    end
  end

  return false
end

---Checks whether a color is a named color e.g. 'blue', 'green'
---@usage is_named_color({M.get_css_named_color_pattern()}, ": blue") => Returns true
---@usage is_named_color({M.get_tailwind_named_color_pattern()}, "--bg-white") => Returns true
---@return boolean
function M.is_named_color(named_color_patterns, color)
  for _, pattern in pairs(named_color_patterns) do
    if string.match(color, pattern) then
      return true
    end
  end

  return false
end

---Checks whether a color is a ansi color
---@param color string
---@usage is_ansi_color("\\033[1;37m") => Returns true
---@return boolean
function M.is_ansi_color(color)
  return string.match(color, M.ansi_regex) ~= nil
end

---Checks whether a color is oklch
---@param color string
---@usage is_oklch_color("oklch(40% 0.268 34.8deg)") => Returns true
---@return boolean
function M.is_oklch_color(color)
  return string.match(color, M.oklch_regex) ~= nil
end

return M
