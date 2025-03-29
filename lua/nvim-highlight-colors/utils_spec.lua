
local assert = require("luassert")
local utils = require("nvim-highlight-colors.utils")

-- Needed to mock vim calls
_G.vim = _G.vim or { api = function() end, fn = function() return {} end }

describe('Utils', function()
	it('should return last row index', function()
		stub(vim, "fn")
		stub(vim.fn, "line").returns(10)
		local last_row_index = utils.get_last_row_index()
		assert.are.equal(last_row_index, 10)
	end)

	it('should return visible rows', function()
		stub(vim, "api")
		stub(vim.api, "nvim_win_call").returns({10, 15})
		stub(vim, "fn")
		stub(vim.fn, "bufwinid").returns(1)
		local visible_rows = utils.get_visible_rows_by_buffer_id(1)
		assert.are.equal(visible_rows[1], 10)
		assert.are.equal(visible_rows[2], 15)
	end)

	it('should create highlight name', function()
		assert.are.equal(
			utils.create_highlight_name("#FFFFFF"),
			"nvim-highlight-colors-FFFFFF"
		)
		assert.are.equal(
			utils.create_highlight_name("0xFFFF00"),
			"nvim-highlight-colors-0xFFFF00"
		)
		assert.are.equal(
			utils.create_highlight_name("rgb(255, 255, 255)"),
			"nvim-highlight-colors-rgb255255255"
		)
		assert.are.equal(
			utils.create_highlight_name("rgba(255 255 255 0.4)"),
			"nvim-highlight-colors-rgba25525525504"
		)
		assert.are.equal(
			utils.create_highlight_name("rgba(0, 255, 0 / 20%)"),
			"nvim-highlight-colors-rgba0255020"
		)
		assert.are.equal(
			utils.create_highlight_name("rgba(0, 255, 0 / .2)"),
			"nvim-highlight-colors-rgba025502"
		)
		assert.are.equal(
			utils.create_highlight_name("hsl(240, 100%, 68%)"),
			"nvim-highlight-colors-hsl24010068"
		)
		assert.are.equal(
			utils.create_highlight_name("hsl(150deg 30% 40%) "),
			"nvim-highlight-colors-hsl150deg3040"
		)
		assert.are.equal(
			utils.create_highlight_name("hsl(0.3turn 60% 15%)"),
			"nvim-highlight-colors-hsl03turn6015"
		)
		assert.are.equal(
			utils.create_highlight_name("bg-sky-50"),
			"nvim-highlight-colors-bgsky50"
		)
		assert.are.equal(
			utils.create_highlight_name("var(--testing-color)"),
			"nvim-highlight-colors-vartestingcolor"
		)
		assert.are.equal(
			utils.create_highlight_name("\\033[0;30m"),
			"nvim-highlight-colors-030m"
		)
		assert.are.equal(
			utils.create_highlight_name("blue"),
			"nvim-highlight-colors-blue"
		)
	end)

	it('should return create highlight for hex color in foreground mode', function()
		spy.on(vim.api, "nvim_set_hl")
		spy.on(vim.api, "nvim_buf_add_highlight")
		local params = {
			buffer_id = 1,
			ns_id = 2,
			data = {
				row = 1, start_column = 3, end_column = 10, value = "#FFFFFF"
			},
			options = {
				render = "foreground"
			}
		}
		utils.create_highlight(
			params.buffer_id,
			params.ns_id,
			params.data,
			params.options
		)
		assert.spy(vim.api.nvim_set_hl).was.called_with(
			0,
			"nvim-highlight-colors-foregroundFFFFFFFFFFFF",
			{fg = "#FFFFFF", default = true}
		)

		assert.spy(vim.api.nvim_buf_add_highlight).was.called_with(
			params.buffer_id,
			params.ns_id,
			"nvim-highlight-colors-foregroundFFFFFFFFFFFF",
			params.data.row + 1,
			params.data.start_column,
			params.data.end_column
		)
	end)

	it('should return create highlight for hex color in background mode', function()
		stub(vim, "tbl_map").returns({255, 255, 255})
		spy.on(vim.api, "nvim_set_hl")
		spy.on(vim.api, "nvim_buf_add_highlight")
		local params = {
			buffer_id = 1,
			ns_id = 2,
			data = {
				row = 1, start_column = 3, end_column = 10, value = "#FFFFFF"
			},
			options = {
				render = "background"
			}
		}
		utils.create_highlight(
			params.buffer_id,
			params.ns_id,
			params.data,
			params.options
		)
		assert.spy(vim.api.nvim_set_hl).was.called_with(
			0,
			"nvim-highlight-colors-backgroundFFFFFFFFFFFF",
			{fg = "#000000", bg = "#FFFFFF", default = true}
		)
		assert.spy(vim.api.nvim_buf_add_highlight).was.called_with(
			params.buffer_id,
			params.ns_id,
			"nvim-highlight-colors-backgroundFFFFFFFFFFFF",
			params.data.row + 1,
			params.data.start_column,
			params.data.end_column
		)
	end)

	it('should return create highlight for short hex color in background mode', function()
		stub(vim, "tbl_map").returns({255, 255, 255})
		spy.on(vim.api, "nvim_set_hl")
		local params = {
			buffer_id = 1,
			ns_id = 2,
			data = {
				row = 1, start_column = 3, end_column = 10, value = "#FFF"
			},
			options = {
				render = "background",
				enable_short_hex = true
			}
		}
		utils.create_highlight(
			params.buffer_id,
			params.ns_id,
			params.data,
			params.options
		)
		assert.spy(vim.api.nvim_set_hl).was.called_with(
			0,
			"nvim-highlight-colors-backgroundFFFFFFFFF",
			{fg = "#000000", bg = "#FFFFFF", default = true}
		)
		assert.spy(vim.api.nvim_buf_add_highlight).was.called_with(
			params.buffer_id,
			params.ns_id,
			"nvim-highlight-colors-backgroundFFFFFFFFFFFF",
			params.data.row + 1,
			params.data.start_column,
			params.data.end_column
		)
	end)

	it('should return create highlight for custom colors in background mode', function()
		stub(vim, "tbl_map").returns({255, 255, 255})
		spy.on(vim.api, "nvim_set_hl")
		local params = {
			buffer_id = 1,
			ns_id = 2,
			data = {
				row = 1, start_column = 3, end_column = 10, value = "custom-color"
			},
			options = {
				render = "background",
				custom_colors = {{label = "custom%-color", color = '#FFFFFF'}}
			}
		}

		utils.create_highlight(
			params.buffer_id,
			params.ns_id,
			params.data,
			params.options
		)
		assert.spy(vim.api.nvim_set_hl).was.called_with(
			0,
			"nvim-highlight-colors-backgroundcustomcolorFFFFFF",
			{fg = "#000000", bg = "#FFFFFF", default = true}
		)

		assert.spy(vim.api.nvim_buf_add_highlight).was.called_with(
			params.buffer_id,
			params.ns_id,
			"nvim-highlight-colors-backgroundcustomcolorFFFFFF",
			params.data.row + 1,
			params.data.start_column,
			params.data.end_column
		)
	end)
end)
