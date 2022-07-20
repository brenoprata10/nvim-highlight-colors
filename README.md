# nvim-highlight-colors
Highlight colors with neovim

![image](https://user-images.githubusercontent.com/26099427/179988116-ff24d0a7-084d-403f-bca8-63dd7bb08fed.png)

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
