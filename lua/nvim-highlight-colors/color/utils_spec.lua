local utils = require("nvim-highlight-colors.color.utils")
local assert = require("luassert")
local buffer_utils = require("nvim-highlight-colors.buffer_utils")

-- Needed to mock vim calls
_G.vim = _G.vim or { tbl_map = function() end, fn = function() return {} end }

describe('Color Utils', function()
	it('should return readable foreground color for bright colors', function()
		stub(vim, "tbl_map").returns({255, 255, 255})
		local hex_value = utils.get_foreground_color_from_hex_color("#FFFFFF")
		assert.are.equal(hex_value, '#000000')
	end)

	it('should return readable foreground color for darker colors', function()
		stub(vim, "tbl_map").returns({0, 0, 0})
		local hex_value = utils.get_foreground_color_from_hex_color("#000000")
		assert.are.equal(hex_value, '#ffffff')
	end)

	it('should return css var color when get_css_var_color received valid hex color', function()
		-- Mock vim.fn.line call
		stub(vim, "fn").returns({line = function() end})
		stub(vim.fn, "line")
		stub(buffer_utils,"get_positions_by_regex").returns({{value = "#000000"}})
		local hex_value = utils.get_css_var_color("--css-variable-name", 0)
		assert.are.equal(hex_value, '#000000')

	end)

	it('should return css var color when get_css_var_color received valid rgb color', function()
		-- Mock vim.fn.line call
		stub(vim, "fn").returns({line = function() end})
		stub(vim.fn, "line")
		stub(buffer_utils,"get_positions_by_regex").returns({{value = "rgb(0, 0, 0)"}})
		local hex_value = utils.get_css_var_color("--css-variable-name", 0)
		assert.are.equal(hex_value, '#000000')

	end)

	it('should return css var color when get_css_var_color received valid hsl color', function()
		-- Mock vim.fn.line call
		stub(vim, "fn").returns({line = function() end})
		stub(vim.fn, "line")
		stub(buffer_utils,"get_positions_by_regex").returns({{value = "hsl(0, 0, 0)"}})
		local hex_value = utils.get_css_var_color("--css-variable-name", 0)
		assert.are.equal(hex_value, '#000000')

	end)

	it('should return css var color when get_css_var_color received valid hsl without func color', function()
		-- Mock vim.fn.line call
		stub(vim, "fn").returns({line = function() end})
		stub(vim.fn, "line")
		stub(buffer_utils,"get_positions_by_regex").returns({{value = ": 0 0% 0%"}})
		local hex_value = utils.get_css_var_color("--css-variable-name", 0)
		assert.are.equal(hex_value, '#000000')

	end)

	it('get_css_var_color should return nil when get_positions_by_regex returns empty array', function()
		-- Mock vim.fn.line call
		stub(vim, "fn").returns({line = function() end})
		stub(vim.fn, "line")
		stub(buffer_utils,"get_positions_by_regex").returns({})
		local hex_value = utils.get_css_var_color("--css-variable-name", 0)
		assert.is_nil(hex_value)

	end)

	it('should return ansi color value', function()
		local hex_value = utils.get_ansi_named_color_value("\\033[1;37m")
		assert.are.equal(hex_value, "#FFFFFF")
	end)

	it('should return nil if ansi color is invalid', function()
		local hex_value = utils.get_ansi_named_color_value("\\033[9;37m")
		assert.is_nil(hex_value)
	end)

	it('should return tailwind color value', function()
		local hex_value = utils.get_tailwind_named_color_value("bg-white")
		assert.are.equal(hex_value, "#FFFFFF")
	end)

	it('should return nil if tailwind color is invalid', function()
		local hex_value = utils.get_ansi_named_color_value("bgwhite")
		assert.is_nil(hex_value)
	end)

	it('should return css named color value', function()
		local hex_value = utils.get_css_named_color_value("black")
		assert.are.equal(hex_value, "#000000")
	end)

	it('should return nil if css color is invalid', function()
		local hex_value = utils.get_ansi_named_color_value("back")
		assert.is_nil(hex_value)
	end)

	it('should return rgb color properties', function()
		local hsl_table = utils.get_rgb_values("rgb(92, 92, 255)")
		assert.are.equal(hsl_table[1], '92')
		assert.are.equal(hsl_table[2], '92')
		assert.are.equal(hsl_table[3], '255')
	end)

	it('should return rgba color properties', function()
		local hsl_table = utils.get_rgb_values("rgba(92 92 255 20%)")
		assert.are.equal(hsl_table[1], '92')
		assert.are.equal(hsl_table[2], '92')
		assert.are.equal(hsl_table[3], '255')
		assert.are.equal(hsl_table[4], '20')
	end)

	it('should return hsl color properties', function()
		local hsl_table = utils.get_hsl_values("hsl(240, 100%, 68%)")
		assert.are.equal(hsl_table[1], '240')
		assert.are.equal(hsl_table[2], '100')
		assert.are.equal(hsl_table[3], '68')
	end)

	it('should return hsl color properties when receiving css variable name', function()
		local hsl_table = utils.get_hsl_without_func_values("--name: 0 0% 100%;")
		assert.are.equal(hsl_table[1], '0')
		assert.are.equal(hsl_table[2], '0')
		assert.are.equal(hsl_table[3], '100')
	end)
end)
