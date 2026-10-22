local assert = require("luassert")
local colors = require("nvim-highlight-colors.color.utils")
local patterns = require("nvim-highlight-colors.color.patterns")
local buffer_utils = require("nvim-highlight-colors.buffer_utils")

-- Needed to mock vim calls
_G.vim = _G.vim or { api = function() end, fn = function() return {} end }

describe('Buffer Utils', function()
	it('should return buffer content', function()
		local buffer_stub_content = "test"
		-- Mock vim.api call
		stub(vim, "api")
		stub(vim.api, "nvim_buf_is_valid").returns(true)
		stub(vim.api, "nvim_buf_get_lines").returns({buffer_stub_content})
		local buffer_contents = buffer_utils.get_buffer_contents(0, 10, 1)
		assert.are.equal(buffer_contents[1], buffer_stub_content)
	end)

	it('should return array with empty string if buffer is invalid', function()
		-- Mock vim.api call
		stub(vim, "api")
		stub(vim.api, "nvim_buf_is_valid").returns(false)
		local buffer_contents = buffer_utils.get_buffer_contents(0, 10, 1)
		assert.are.equal(buffer_contents[1], "")
	end)

	it('should return array with hex color positions', function()
		-- Mock vim.fn.line call
		stub(vim, "fn")
		stub(vim.fn, "match").returns({1, 1})
		stub(vim.fn, "matchend").returns({1, 1})
		stub(buffer_utils, "get_buffer_contents").returns({
			"color: #FFFFFF;",
			"padding: 30px;",
			"background-color: #000000;",
			"background: rgb(255, 255, 255);",
		})
		local buffer_contents = buffer_utils.get_positions_by_regex({
			patterns.hex_regex,
			patterns.hex_0x_regex
		}, 0, 10, 1, 0)
		assert.are.equal(buffer_contents[1].value, "#FFFFFF")
		assert.are.equal(buffer_contents[2].value, "#000000")
	end)

	it('should return array with rgb color positions', function()
		-- Mock vim.fn.line call
		stub(vim, "fn")
		stub(vim.fn, "match").returns({1, 1})
		stub(vim.fn, "matchend").returns({1, 1})
		stub(buffer_utils, "get_buffer_contents").returns({
			"border-color: #FFFFFF;",
			"padding: 30px;",
			"background: rgb(255 255 255);",
			"color: rgba(55, 255, 25, 0.2);",
			"color: rgba(55 255 25 / .2);",
			"background-color: #000000;",
		})
		local buffer_contents = buffer_utils.get_positions_by_regex({
			patterns.rgb_regex,
		}, 0, 10, 1, 0)
		assert.are.equal(buffer_contents[1].value, "rgb(255 255 255)")
		assert.are.equal(buffer_contents[2].value, "rgba(55, 255, 25, 0.2)")
		assert.are.equal(buffer_contents[3].value, "rgba(55 255 25 / .2)")
	end)

	it('should return array with hsl color positions', function()
		-- Mock vim.fn.line call
		stub(vim, "fn")
		stub(vim.fn, "match").returns({1, 1})
		stub(vim.fn, "matchend").returns({1, 1})
		stub(buffer_utils, "get_buffer_contents").returns({
			"border-color: #FFFFFF;",
			"background: hsl(240, 100%, 68%);",
			"color: hsl(150deg 30% 40%);",
			"background-color: hsl(0.3turn 60% 15%);",
			"padding: 30px;",
		})
		local buffer_contents = buffer_utils.get_positions_by_regex({
			patterns.hsl_regex
		}, 0, 10, 1, 0)
		assert.are.equal(buffer_contents[1].value, "hsl(240, 100%, 68%)")
		assert.are.equal(buffer_contents[2].value, "hsl(150deg 30% 40%)")
		assert.are.equal(buffer_contents[3].value, "hsl(0.3turn 60% 15%)")
	end)

	it('should return array with hsl color without func positions', function()
		-- Mock vim.fn.line call
		stub(vim, "fn")
		stub(vim.fn, "match").returns({1, 1})
		stub(vim.fn, "matchend").returns({1, 1})
		stub(buffer_utils, "get_buffer_contents").returns({
			"border-color: #FFFFFF;",
			"background: 240, 100%, 68%;",
			"color: 150deg 30% 40%;",
			"background-color: hsl(1turn 20% 15%);",
			"background-color: 0.3turn 60% 15%;",
			"padding: 30px;",
		})
		local buffer_contents = buffer_utils.get_positions_by_regex({
			patterns.hsl_without_func_regex
		}, 0, 10, 1, 0)
		assert.are.equal(buffer_contents[1].value, ": 240, 100%, 68%")
		assert.are.equal(buffer_contents[2].value, ": 150deg 30% 40%")
		assert.are.equal(buffer_contents[3].value, ": 0.3turn 60% 15%")
	end)

	it('should return array with css variable color positions', function()
		-- Mock vim.fn.line call
		stub(vim, "fn")
		stub(vim.fn, "match").returns({1, 1})
		stub(vim.fn, "matchend").returns({1, 1})
		stub(buffer_utils, "get_buffer_contents").returns({
			"border-color: #FFFFFF;",
			"background: var(--background-theme)",
			"color: 150deg 30% 40%;",
			"background-color: hsl(1turn 20% 15%);",
			"background-color: var(--theme-ui);",
			"padding: 30px;",
		})
		local buffer_contents = buffer_utils.get_positions_by_regex({
			patterns.var_usage_regex
		}, 0, 10, 1, 0)
		assert.are.equal(buffer_contents[1].value, "var(--background-theme)")
		assert.are.equal(buffer_contents[2].value, "var(--theme-ui)")
	end)

	it('should return array with css color positions', function()
		-- Mock vim.fn.line call
		stub(vim, "fn")
		stub(vim.fn, "match").returns({1, 1})
		stub(vim.fn, "matchend").returns({1, 1})
		stub(buffer_utils, "get_buffer_contents").returns({
			"border-color: #FFFFFF;",
			"background: black",
			"color: 150deg 30% 40%;",
			"background-color: white;",
			"background-color: green;",
			"padding: 30px;",
		})
		local buffer_contents = buffer_utils.get_positions_by_regex({
			colors.get_css_named_color_pattern()
		}, 0, 10, 1, 0)
		assert.are.equal(buffer_contents[1].value, ": black")
		assert.are.equal(buffer_contents[2].value, ": white")
		assert.are.equal(buffer_contents[3].value, ": green")
	end)

	it('should return array with tailwind color positions', function()
		-- Mock vim.fn.line call
		stub(vim, "fn")
		stub(vim.fn, "match").returns({1, 1})
		stub(vim.fn, "matchend").returns({1, 1})
		stub(buffer_utils, "get_buffer_contents").returns({
			"className=\"bg-white\"",
			"color: 150deg 30% 40%;",
			"className=\"text-slate-600\"",
			"padding: 30px;",
		})
		local buffer_contents = buffer_utils.get_positions_by_regex({
			colors.get_tailwind_named_color_pattern()
		}, 0, 10, 1, 0)
		assert.are.equal(buffer_contents[1].value, "bg-white")
		assert.are.equal(buffer_contents[2].value, "text-slate-600")
	end)

	it('should return array with ansi color positions', function()
		-- Mock vim.fn.line call
		stub(vim, "fn")
		stub(vim.fn, "match").returns({1, 1})
		stub(vim.fn, "matchend").returns({1, 1})
		stub(buffer_utils, "get_buffer_contents").returns({
			"\\033[0;30m",
			"background: var(--background-theme)",
			"color: 150deg 30% 40%;",
			"\\033[1;30m",
			"background-color: var(--theme-ui);",
			"padding: 30px;",
		})
		local buffer_contents = buffer_utils.get_positions_by_regex({
			patterns.ansi_regex
		}, 0, 10, 1, 0)
		assert.are.equal(buffer_contents[1].value, "\\033[0;30m")
		assert.are.equal(buffer_contents[2].value, "\\033[1;30m")
	end)

	describe('color match positions', function()
		local function positions_for(line, pattern)
			stub(buffer_utils, "get_buffer_contents").returns({line})
			return buffer_utils.get_positions_by_regex({pattern}, 0, 1, 1, 0)
		end

		it('should highlight the property value instead of the same color in a selector', function()
			local positions = positions_for(
				"    .named-orange { background-color: orange; }",
				colors.get_css_named_color_pattern()
			)
			assert.are.same({
				{value = ": orange", row = 1, start_column = 38, end_column = 44},
			}, positions)
		end)

		it('should locate repeated named colors with different whitespace', function()
			local positions = positions_for(
				".many { color: orange; border-color:orange; }",
				colors.get_css_named_color_pattern()
			)
			assert.are.same({
				{value = ": orange", row = 1, start_column = 15, end_column = 21},
				{value = ":orange", row = 1, start_column = 36, end_column = 42},
			}, positions)
		end)

		it('should locate repeated named colors with different quotes', function()
			local positions = positions_for(
				[[first = "orange"; second = 'orange']],
				colors.get_css_named_color_pattern()
			)
			assert.are.same({
				{value = [[= "orange]], row = 1, start_column = 9, end_column = 15},
				{value = "= 'orange", row = 1, start_column = 28, end_column = 34},
			}, positions)
		end)

		it('should keep separate positions for repeated hex colors', function()
			local positions = positions_for(
				".many { color: #fff; background: #fff; }",
				patterns.hex_regex
			)
			assert.are.same({
				{value = "#fff", row = 1, start_column = 15, end_column = 19},
				{value = "#fff", row = 1, start_column = 33, end_column = 37},
			}, positions)
		end)

		it('should preserve byte offsets after multibyte text', function()
			local positions = positions_for("背景: orange", colors.get_css_named_color_pattern())
			assert.are.same({
				{value = ": orange", row = 1, start_column = 8, end_column = 14},
			}, positions)
		end)

		it('should preserve Lua pattern matches containing regex metacharacters', function()
			local positions = positions_for("theme[primary]", "theme%[primary%]")
			assert.are.same({
				{value = "theme[primary]", row = 1, start_column = 0, end_column = 14},
			}, positions)
		end)

		it('should advance past zero-width matches', function()
			local positions = positions_for("a b", "%f[%a]")
			assert.are.same({
				{value = "", row = 1, start_column = 0, end_column = 0},
				{value = "", row = 1, start_column = 2, end_column = 2},
			}, positions)
		end)
	end)

	it('should return column offset for repeated colors', function()
		local row = 1
		local match = "#fff"
		local column_offset = buffer_utils.get_column_offset({
			{row = row, start_column = 1, end_column = 4, value = match}
		}, match, row)
		assert.are.equal(column_offset, 4)
	end)

	it('should return nil if column offset does not match', function()
		local row = 1
		local match = "#ffffff"
		local column_offset = buffer_utils.get_column_offset({
			{row = row, start_column = 1, end_column = 4, value = match}
		}, "#fff", row)
		assert.is_nil(column_offset)
	end)

	it('should remove color usage string from match', function()
		local match = ": blue"
		local color = buffer_utils.remove_color_usage_pattern(match)
		assert.are.equal(color, "blue")

		local match2 = "= blue"
		local color2 = buffer_utils.remove_color_usage_pattern(match2)
		assert.are.equal(color2, "blue")
	end)

	it('should return match when color usage is not detected', function()
		local match = " blue  "
		local color = buffer_utils.remove_color_usage_pattern(match)
		assert.are.equals(color, match)
	end)
end)
