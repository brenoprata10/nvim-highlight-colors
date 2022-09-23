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
There are only two available command for now:
| Command   |      Description      |
|----------|:-------------:|
| HighlightColorsOn |  Turns on highlight feature |
| HighlightColorsOff |    Turns off highlight feature   |
| HighlightColorsToggle |    Toggles highlight feature   |

You might also use:
```
lua require("nvim-highlight-colors").turnOff()
lua require("nvim-highlight-colors").turnOn()
lua require("nvim-highlight-colors").toggle()
```

## Customization
| Property |      Options      | Description
|----------|:-------------:|:----------:|
| render |  background(default), first_column, foreground | Changes how the colors will be rendered |
| enable_tailwind |  boolean(defaults to `false`) | Adds highlight to tailwind colors |

Here is how you might use the options:
```
lua require("nvim-highlight-colors").setup {
	render = 'background', -- or 'foreground' or 'first_column'
	enable_tailwind = false
}
```
## Screenshots
Tailwind CSS support:

![Screenshot from 2022-08-14 16-49-35](https://user-images.githubusercontent.com/26099427/184542562-855fcdd4-c08d-4805-b756-8cbbf442382f.png)

## TODO
- [X] Add RGB support
- [X] Add RGBA support
- [X] Multicolor per line support (for 'foreground' and 'background' render mode)
- [X] Detect variables in css files and evaluate their value
- [X] Create `Toggle` option for better usability
- [X] Add option config to colorize whole background of colors(much like `colorizer` plugin)
- [ ] Detect SCSS variable in scss files and evaluate their value
- [ ] Detect Stylus variable in styl files and evaluate their value
