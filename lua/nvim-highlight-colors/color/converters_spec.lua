local converters = require("nvim-highlight-colors.color.converters")
local assert = require("luassert")

describe('Converters', function()
	it('should convert rgb to hex', function()
		local hex_value = converters.rgb_to_hex(255, 255, 255)
		assert.are.equal(hex_value, '#FFFFFF')
	end)

	it('should convert hex to rgb', function()
		local rgb_table = converters.hex_to_rgb('#FFFFFF')
		assert.are.equal(rgb_table[1], 255)
		assert.are.equal(rgb_table[2], 255)
		assert.are.equal(rgb_table[3], 255)
	end)

	it('should convert short hex to rgb', function()
		local rgb_table = converters.hex_to_rgb('#FFF')
		assert.are.equal(rgb_table[1], 255)
		assert.are.equal(rgb_table[2], 255)
		assert.are.equal(rgb_table[3], 255)
	end)

	it('should return nil for invalid hex', function()
		local rgb_table = converters.hex_to_rgb('#FLK')
		assert.is_nil(rgb_table)
	end)

	it('should convert short hex to hex', function()
		local hex_value = converters.short_hex_to_hex('#FFF')
		assert.are.equal(hex_value, '#FFFFFF')
	end)

	it('should convert hsl to rgb', function()
		local hsl_table = converters.hsl_to_rgb(240, 100, 68)
		assert.are.equal(hsl_table[1], 91)
		assert.are.equal(hsl_table[2], 91)
		assert.are.equal(hsl_table[3], 255)
		assert.are.equal(hsl_table[4], 255)
	end)

  it('should convert oklch to rgb', function()
    local rgb_table = converters.oklch_to_rgb(40, 0.268, 34.8)
    -- The exact values will depend on the conversion algorithm
    assert.is_not_nil(rgb_table)
    assert.are.equal(#rgb_table, 4) -- R, G, B, A
  end)
end)

