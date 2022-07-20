# nvim-highlight-colors
Highlight colors with neovim

![image](https://user-images.githubusercontent.com/26099427/179988116-ff24d0a7-084d-403f-bca8-63dd7bb08fed.png)

## Features
- Displays colors based on their HEX value
- Super fast no matter the amount of colors
- See the colors change as you edit them

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

## Limitations
- This plugin was developed with CSS in mind, so the color will take up the space of the first available column in the buffer
- Only one color per line

## TODO
- Add RGB support
- Add RGBA support
- Detect variables in css files and evaluate their value
