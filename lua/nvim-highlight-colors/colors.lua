local buffer_utils = require("nvim-highlight-colors.buffer_utils")
local table_utils  = require("nvim-highlight-colors.table_utils")

local M = {}

M.rgb_regex = "rgba?[(]+" .. string.rep("%s*%d+%s*", 3, "[, ]") .. "[, /]?%s*%d*%.?%d*%s*[)]+"
M.hex_regex = "#[%a%d]+[%a%d]+[%a%d]+"
M.var_regex = "%-%-[%d%a-_]+"
M.var_declaration_regex = M.var_regex .. ":%s*" .. M.hex_regex
M.var_usage_regex = "var%(" .. M.var_regex .. "%)"

function M.get_color_value(color, row_offset)
    if (M.is_short_hex_color(color)) then
        return M.convert_short_hex_to_hex(color)
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

function M.is_short_hex_color(color)
    return string.len(color) == 4
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
        for char in color:gmatch "." do
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
    local color_score = 0
    local color_threshhold = 40

    for value in string.gmatch(color, ".") do
        if type(value) == "number" then
            color_score = color_score + value
        elseif string.lower(value) == 'a' then
            color_score = color_score + 10
        elseif string.lower(value) == 'b' then
            color_score = color_score + 11
        elseif string.lower(value) == 'c' then
            color_score = color_score + 12
        elseif string.lower(value) == 'd' then
            color_score = color_score + 13
        elseif string.lower(value) == 'e' then
            color_score = color_score + 14
        elseif string.lower(value) == 'f' then
            color_score = color_score + 15
        end
    end

    return color_score >= color_threshhold and "#000000" or "#ffffff"
end

return M
