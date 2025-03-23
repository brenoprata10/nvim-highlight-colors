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
