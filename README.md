# nvim-highlight-colors
Highlight colors with neovim

![image](https://user-images.githubusercontent.com/26099427/179988116-ff24d0a7-084d-403f-bca8-63dd7bb08fed.png)

## Features
- Displays colors based on their HEX/rgb/hsl value
- Super fast no matter the amount of colors
- See the colors change as you edit them
- CSS variables support
- Tailwind CSS support

## Installation
Add this to your init.vim
```
set termguicolors
set t_Co=256
```

Install plugin with Plug:
```
Plug 'brenoprata10/nvim-highlight-colors'
```

Call `setup` function to initialize plugin by default:
```
require('nvim-highlight-colors').setup {}
```

## Commands
There are only three available commands for now:
| Command   |      Description      |
|----------|:-------------:|
| HighlightColors On |  Turns on highlight feature |
| HighlightColors Off |  Turns off highlight feature   |
| HighlightColors Toggle |  Toggles highlight feature   |

You might also use:
```
lua require("nvim-highlight-colors").turnOff()
lua require("nvim-highlight-colors").turnOn()
lua require("nvim-highlight-colors").toggle()
```

## Customization
| Property |      Options      | Description
|----------|:-------------:|:----------:|
| render |  background(default), foreground | Changes how the colors will be rendered |
| enable_named_colors |  boolean(defaults to `true`) | Adds highlight to css color names |
| enable_tailwind |  boolean(defaults to `false`) | Adds highlight to tailwind colors |
| custom_colors | `Array<{label: string, color: string}>` | Adds custom colors based on declared label |

Here is how you might use the options:
```
lua require("nvim-highlight-colors").setup {
	render = 'background', -- or 'foreground'
	enable_named_colors = true,
	enable_tailwind = false,
	custom_colors = {
		-- label property will be used as a pattern initially(string.gmatch), therefore you need to escape the special characters by yourself with % 
		{label = '%-%-theme%-font%-color', color = '#fff'},
		{label = '%-%-theme%-background%-color', color = '#23222f'},
		{label = '%-%-theme%-primary%-color', color = '#0f1219'},
		{label = '%-%-theme%-secondary%-color', color = '#5a5d64'},
		{label = '%-%-theme%-contrast%-color', color = '#fff'},
		{label = '%-%-theme%-accent%-color', color = '#55678e'},
	}
}
```
Custom colors support:

![image](https://user-images.githubusercontent.com/26099427/227793884-ebabe163-0e19-4be6-8bf6-e4a904de5e6d.png)

Tailwind CSS support:

![Screenshot from 2022-08-14 16-49-35](https://user-images.githubusercontent.com/26099427/184542562-855fcdd4-c08d-4805-b756-8cbbf442382f.png)
