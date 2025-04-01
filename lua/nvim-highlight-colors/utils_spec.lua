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

	it('should create highlight for hex color in foreground mode', function()
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

	it('should create highlight for hex color in background mode', function()
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

	it('should not call highlight_extmarks in background mode', function()
		stub(vim, "tbl_map").returns({255, 255, 255})
		spy.on(vim.api, "nvim_set_hl")
		spy.on(vim.api, "highlight_extmarks")
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
		assert.spy(vim.api.highlight_extmarks).was_not_called()
	end)

	it('should not call highlight_extmarks in foreground mode', function()
		spy.on(vim.api, "nvim_set_hl")
		spy.on(vim.api, "highlight_extmarks")
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
		assert.spy(vim.api.highlight_extmarks).was_not_called()
	end)

	it('should create highlight for short hex color in background mode', function()
		stub(vim, "tbl_map").returns({255, 255, 255})
		spy.on(vim.api, "nvim_set_hl")
		spy.on(vim.api, "nvim_buf_add_highlight")
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
			"nvim-highlight-colors-backgroundFFFFFFFFF",
			params.data.row + 1,
			params.data.start_column,
			params.data.end_column
		)
	end)

	it('should create highlight for custom colors in background mode', function()
		stub(vim, "tbl_map").returns({255, 255, 255})
		spy.on(vim.api, "nvim_set_hl")
		spy.on(vim.api, "nvim_buf_add_highlight")
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

	it('should create highlight for hex colors in virtual mode', function()
		stub(vim, "version").returns({major = 0, minor = 10})
		stub(vim.api, "nvim_buf_get_extmarks").returns({})
		stub(vim.api, "nvim_buf_del_extmark")
		stub(vim.api, "nvim_get_hl_id_by_name").returns(2)
		spy.on(vim.api, "nvim_buf_set_extmark")
		local params = {
			buffer_id = 1,
			ns_id = 2,
			data = {
				row = 1, start_column = 3, end_column = 10, value = "#FFFFFF"
			},
			options = {
				render = "virtual",
				virtual_symbol_position = 'inline',
				virtual_symbol = "■",
				virtual_symbol_prefix = "_",
				virtual_symbol_suffix = "=",
			}
		}

		utils.create_highlight(
			params.buffer_id,
			params.ns_id,
			params.data,
			params.options
		)

		assert.spy(vim.api.nvim_buf_set_extmark).was.called_with(
			params.buffer_id,
			params.ns_id,
			params.data.row + 1,
			params.data.start_column,
			{
				hl_mode = 'combine',
				virt_text = {
					{
						'_■=',
						2
					},
				},
				virt_text_pos = 'inline'
			}
		)
	end)

	it('should replace highlight for hex colors in virtual mode', function()
		stub(vim, "version").returns({major = 0, minor = 10})
		stub(vim.api, "nvim_buf_del_extmark")
		stub(vim.api, "nvim_get_hl_id_by_name").returns(2)
		spy.on(vim.api, "nvim_buf_set_extmark")
		spy.on(vim.api, "nvim_buf_del_extmark")
		local params = {
			buffer_id = 1,
			ns_id = 2,
			data = {
				row = 1, start_column = 3, end_column = 10, value = "#FFFFFF"
			},
			highlight_group = "nvim-highlight-colors-virtualFFFFFF",
			options = {
				render = "virtual",
				virtual_symbol_position = 'inline',
				virtual_symbol = "■",
				virtual_symbol_prefix = "",
				virtual_symbol_suffix = "",
			}
		}
		local already_highlighted_extmark_id = 35
		local already_highlighted_group = "nvim-highlight-colors-virtual000000"
		local extmart_data = {virt_text = {{0, already_highlighted_group}}}
		stub(vim, "deepcopy").returns(extmart_data)
		stub(vim.api, "nvim_buf_get_extmarks").returns({{already_highlighted_extmark_id, 0, 0, extmart_data}})

		utils.highlight_extmarks(
			params.buffer_id,
			params.ns_id,
			params.data,
			params.highlight_group,
			params.options
		)

		assert.spy(vim.api.nvim_buf_del_extmark).was.called_with(
			params.buffer_id,
			params.ns_id,
			already_highlighted_extmark_id
		)

		assert.spy(vim.api.nvim_buf_set_extmark).was.called_with(
			params.buffer_id,
			params.ns_id,
			params.data.row + 1,
			params.data.start_column,
			{
				hl_mode = 'combine',
				virt_text = {
					{
						'■',
						2
					},
				},
				virt_text_pos = 'inline'
			}
		)
	end)

	it('should skip virtual highlight if text is already highlighted', function()
		stub(vim, "version").returns({major = 0, minor = 10})
		stub(vim.api, "nvim_buf_del_extmark")
		stub(vim.api, "nvim_get_hl_id_by_name").returns(2)
		spy.on(vim.api, "nvim_buf_set_extmark")
		local params = {
			buffer_id = 1,
			ns_id = 2,
			data = {
				row = 1, start_column = 3, end_column = 10, value = "#FFFFFF"
			},
			highlight_group = "nvim-highlight-colors-virtualFFFFFF",
			options = {
				render = "virtual",
				virtual_symbol_position = 'inline',
				virtual_symbol = "■",
				virtual_symbol_prefix = "",
				virtual_symbol_suffix = "",
			}
		}
		local extmart_data = {virt_text = {{0, params.highlight_group}}}
		stub(vim, "deepcopy").returns(extmart_data)
		stub(vim.api, "nvim_buf_get_extmarks").returns({{0, 0, 0, extmart_data}})

		utils.highlight_extmarks(
			params.buffer_id,
			params.ns_id,
			params.data,
			params.highlight_group,
			params.options
		)

		assert.spy(vim.api.nvim_buf_set_extmark).was_not_called()
	end)

	it('should return true if tailwindcss LSP is available', function()
		stub(utils, "get_lsp_clients").returns({{name = "tailwindcss"}})

		local is_tailwind_available = utils.has_tailwind_css_lsp()

		assert.are.equal(is_tailwind_available, true)
	end)

	it('should return false if tailwindcss LSP is unavailable', function()
		stub(utils, "get_lsp_clients").returns({{name = "some-lsp"}})

		local is_tailwind_available = utils.has_tailwind_css_lsp()

		assert.are.equal(is_tailwind_available, false)
	end)

	it('should return virtual symbol position if neovim version if higher then 0.9', function()
		stub(vim, "version").returns({major = 0, minor = 10})

		assert.are.equal(
			utils.get_virtual_text_position({virtual_symbol_position = "eow"}),
			"eow"
		)
		assert.are.equal(
			utils.get_virtual_text_position({virtual_symbol_position = "eol"}),
			"eol"
		)
		assert.are.equal(
			utils.get_virtual_text_position({virtual_symbol_position = "inline"}),
			"inline"
		)
	end)

	it('should return "eol" as virtual symbol position if neovim version if 0.9 or below', function()
		stub(vim, "version").returns({major = 0, minor = 9})

		assert.are.equal(
			utils.get_virtual_text_position({virtual_symbol_position = "eow"}),
			"eol"
		)
		assert.are.equal(
			utils.get_virtual_text_position({virtual_symbol_position = "eol"}),
			"eol"
		)
		assert.are.equal(
			utils.get_virtual_text_position({virtual_symbol_position = "inline"}),
			"eol"
		)
	end)

	it('should return virtual text column for extmark', function()
		local start_extmark_column = 1
		local end_extmark_column = 10

		assert.are.equal(
			utils.get_virtual_text_column("eol", start_extmark_column, end_extmark_column),
			start_extmark_column
		)
		assert.are.equal(
			utils.get_virtual_text_column("eow", start_extmark_column, end_extmark_column),
			end_extmark_column
		)
		assert.are.equal(
			utils.get_virtual_text_column("inline", start_extmark_column, end_extmark_column),
			start_extmark_column + 1
		)
	end)

	it('should call highlight_lsp_document_color only if supported LSP is detected', function()
		local lsp_response = {"response"}
		stub(vim, "version").returns({major = 0, minor = 11})
		stub(vim, "lsp")
		stub(vim.lsp, "util").returns({make_text_document_params = function () end})
		stub(vim.lsp.util, "make_text_document_params").returns("")
		stub(utils, "get_lsp_clients").returns({
			{
				server_capabilities = {colorProvider = true},
				request = function (_,_,_, handler)
					handler(1, lsp_response)
				end
			},
			{
				server_capabilities = {colorProvider = false},
				request = function (_,_,_, handler)
					handler()
				end
			},
			{
				server_capabilities = {colorProvider = true},
				request = function (_,_,_, handler)
					handler(1, lsp_response)
				end
			}
		})
		spy.on(utils, "highlight_lsp_document_color")
		stub(utils, "highlight_lsp_document_color")


		local params = {
			buffer_id = 1,
			ns_id = 2,
			data = {
				row = 1, start_column = 3, end_column = 10, value = "#FFFFFF"
			},
			options = {
				render = "virtual",
				virtual_symbol_position = 'inline',
				virtual_symbol = "■",
				virtual_symbol_prefix = "",
				virtual_symbol_suffix = "",
			}
		}

		utils.highlight_with_lsp(
			params.buffer_id,
			params.ns_id,
			params.data,
			params.options
		)

		assert.spy(utils.highlight_lsp_document_color).was_called(2)
		assert.spy(utils.highlight_lsp_document_color).was_called_with(
			lsp_response,
			params.buffer_id,
			params.ns_id,
			params.data,
			params.options
		)
	end)
end)
