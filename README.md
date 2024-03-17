# nvim-highlight-colors

> Highlight colors within Neovim

![image](https://github.com/brenoprata10/nvim-highlight-colors/assets/26099427/53a342a8-af88-4a18-961b-73f2a2cd4b2a)

## Features

- Realtime color highlighting
- Supports hex, rgb, hsl, CSS variables, and Tailwind CSS
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

## Options

```lua
require("nvim-highlight-colors").setup {
	---Render style
	---@usage 'background'|'foreground'|'virtual'
	render = 'background',

	---Set virtual symbol (requires render to be set to 'virtual')
	virtual_symbol = '■',

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
	}
}
```

### Tailwind CSS

![Screenshot from 2022-08-14 16-49-35](https://user-images.githubusercontent.com/26099427/184542562-855fcdd4-c08d-4805-b756-8cbbf442382f.png)

### Custom colors

![image](https://user-images.githubusercontent.com/26099427/227793884-ebabe163-0e19-4be6-8bf6-e4a904de5e6d.png)

### Virtual text

![Screenshot of nvim-highlight-colors rendering colors via virtual text](https://github.com/brenoprata10/nvim-highlight-colors/assets/1474821/1534a62b-7214-4344-8316-a687c6f9d709)

## Commands

| Command                   | Description         |
| :------------------------ | :------------------ |
| `:HighlightColors On`     | Turn highlights on  |
| `:HighlightColors Off`    | Turn highlights off |
| `:HighlightColors Toggle` | Toggle highlights   |

Commands are also available in lua:

```lua
require("nvim-highlight-colors").turnOn()
require("nvim-highlight-colors").turnOff()
require("nvim-highlight-colors").toggle()
```
