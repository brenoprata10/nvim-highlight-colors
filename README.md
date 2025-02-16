# nvim-highlight-colors

> Highlight colors within Neovim

<img width="640" src="https://github.com/mvllow/nvim-highlight-colors/assets/1474821/d99a800c-0ea9-44f9-bc1c-986236adf44a" alt="Background highlights for hex, rgb, hsl, named colors, and CSS variables" />

## Features

- Realtime color highlighting
- Supports hex, rgb, hsl, CSS variables, and Tailwind CSS
- LSP support! For any LSP that supports `textDocument/documentColor` like [tailwindcss](https://github.com/tailwindlabs/tailwindcss-intellisense) and [csslsp](https://github.com/microsoft/vscode-css-languageservice)
- Multiple rendering modes: background, foreground, and virtual text

## Usage

Install via your preferred package manager:

```lua
'brenoprata10/nvim-highlight-colors'
```

Initialize the plugin:

```lua
-- Ensure termguicolors is enabled if not already
vim.opt.termguicolors = true

require('nvim-highlight-colors').setup({})
```

### `nvim-cmp` integration

```lua
require("cmp").setup({
        ... other configs
        formatting = {
                format = require("nvim-highlight-colors").format
        }
})
```

or

```lua
require("cmp").setup({
        ... other configs
        formatting = {
                format = function(entry, item)
                        item = -- YOUR other configs come first
                        return require("nvim-highlight-colors").format(entry, item)
                end
        }
})
```

#### `lspkind` integration

The out of the box `format` function does not necessarily play nicely with `lspkind` and potentially other formatters provided by plugins and may require manual intervention. Here is an example of making the integration work nicely with `lspkind`:

```lua
require("cmp").setup({
        ... other configs
        formatting = {
                format = function(entry, item)
                        local color_item = require("nvim-highlight-colors").format(entry, { kind = item.kind })
                        item = require("lspkind").cmp_format({
                                -- any lspkind format settings here
                        })(entry, item)
                        if color_item.abbr_hl_group then
                                item.kind_hl_group = color_item.abbr_hl_group
                                item.kind = color_item.abbr
                        end
                        return item
                end
        }
})
```

### `blink.cmp` integration

```lua
require("blink.cmp").setup {
	completion = {
		menu = {
			draw = {
				components = {
					-- customize the drawing of kind icons
					kind_icon = {
						text = function(ctx)
						  -- default kind icon
						  local icon = ctx.kind_icon
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local color_item = require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
								if color_item and color_item.abbr then
								  icon = color_item.abbr
								end
							end
							return icon .. ctx.icon_gap
						end,
						highlight = function(ctx)
							-- default highlight group
							local highlight = "BlinkCmpKind" .. ctx.kind
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local color_item = require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
								if color_item and color_item.abbr_hl_group then
								  highlight = color_item.abbr_hl_group
								end
							end
							return highlight
						end,
					},
				},
			},
		},
	},
}
```

## Options

```lua
require("nvim-highlight-colors").setup {
	---Render style
	---@usage 'background'|'foreground'|'virtual'
	render = 'background',

	---Set virtual symbol (requires render to be set to 'virtual')
	virtual_symbol = '■',

	---Set virtual symbol suffix (defaults to '')
	virtual_symbol_prefix = '',

	---Set virtual symbol suffix (defaults to ' ')
	virtual_symbol_suffix = ' ',

	---Set virtual symbol position()
 	---@usage 'inline'|'eol'|'eow'
 	---inline mimics VS Code style
 	---eol stands for `end of column` - Recommended to set `virtual_symbol_suffix = ''` when used.
 	---eow stands for `end of word` - Recommended to set `virtual_symbol_prefix = ' ' and virtual_symbol_suffix = ''` when used.
	virtual_symbol_position = 'inline',

	---Highlight hex colors, e.g. '#FFFFFF'
	enable_hex = true,

    	---Highlight short hex colors e.g. '#fff'
	enable_short_hex = true,

	---Highlight rgb colors, e.g. 'rgb(0 0 0)'
	enable_rgb = true,

	---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
	enable_hsl = true,

  -- Highlight hsl colors without function, e.g. '--foreground: 0 69% 69%;'
  enable_hsl_without_function = true,

	---Highlight CSS variables, e.g. 'var(--testing-color)'
	enable_var_usage = true,

	---Highlight named colors, e.g. 'green'
	enable_named_colors = true,

	---Highlight tailwind colors, e.g. 'bg-blue-500'
	enable_tailwind = false,

	---Set custom colors
	---Label must be properly escaped with '%' to adhere to `string.gmatch`
	--- :help string.gmatch
	custom_colors = {
		{ label = '%-%-theme%-primary%-color', color = '#0f1219' },
		{ label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
	},

 	-- Exclude filetypes or buftypes from highlighting e.g. 'exclude_buftypes = {'text'}'
    	exclude_filetypes = {},
    	exclude_buftypes = {},
 	-- Exclude buffer from highlighting e.g. 'exclude_buffer = function(bufnr) return vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr)) > 1000000 end'
    	exclude_buffer = function(bufnr) end
}
```

### Render modes

> Examples shown use `enable_tailwind = true`

**Background**

<img width="640" src="https://github.com/mvllow/nvim-highlight-colors/assets/1474821/bf8c0d2d-552c-485a-aeba-b3d281c8c333" alt="Background highlights for named colors, CSS variables, and Tailwind CSS colors" />

**Foreground**

<img width="640" src="https://github.com/mvllow/nvim-highlight-colors/assets/1474821/4e2e9c7d-552b-4558-ab79-4fe37738f869" alt="Foreground highlights for named colors, CSS variables, and Tailwind CSS colors" />

**Virtual text**

<img width="640" src="https://github.com/mvllow/nvim-highlight-colors/assets/1474821/536b16e4-04ad-4ede-95f5-c1855386c294" alt="Virtual text highlights for named colors, CSS variables, and Tailwind CSS colors" />

**nvim-cmp integration**

![image](https://github.com/brenoprata10/nvim-highlight-colors/assets/26099427/0f6858fe-f7e2-4710-a22f-c3b3a455f74b)


## Commands

| Command                     | Description                  |
| :-------------------------- | :--------------------------- |
| `:HighlightColors On`       | Turn highlights on           |
| `:HighlightColors Off`      | Turn highlights off          |
| `:HighlightColors Toggle`   | Toggle highlights            |
| `:HighlightColors IsActive` | Highlights active / disabled |

Commands are also available in lua:

```lua
require("nvim-highlight-colors").turnOn()
require("nvim-highlight-colors").turnOff()
require("nvim-highlight-colors").toggle()
require("nvim-highlight-colors").is_active()
```
