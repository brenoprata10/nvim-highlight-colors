if exists("g:loaded_nvim-highlight-colors")
	finish
endif

let g:loaded_nvim-highlight-colors = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/example-plugin/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 HighlightColorsOff lua require("nvim-highlight-colors").turnOff()
command! -nargs=0 HighlightColorsOn lua require("nvim-highlight-colors").turnOn()
