# vim-comments-and-headers

### This plugin does the following:
1. It lets you **toggle** comment/uncomment one or multiple lines at a time with a shortcut of your choice. It recognizes your filetype and will comment/uncomment according to that syntax. This is especially useful in languages such as HTML, where comments must be closed at the end of the line (Ex: ```<!-- some html stuff -->```).
2. It automatically creates headers (name & today's date) at the top of any new document you create, or any empty document that you open, and comments out that header using correct syntax based on your filetype. Additionally, you can map a shortcut to add a header to an existing file that doesn't already have one.
3. As soon as you write/save a file that HAS been modified, the header (if one exists) will be updated with the current date.

## INSTALLATION
Insert ```Plug 'ryayoung/vim-comments-and-headers'``` in the plugin section of your ```vimrc```, if you're using Plug as your plugin manager. Run ```:PlugInstall``` after saving and re-opening Vim. If you use a different plugin manager, figure it out.
## HOW TO USE
If you just want to get this plugin working and don't feel like reading, paste the following into your ```vimrc``` file:
```vim
let g:my_name = "Your Name"
" Shortcut to create header in file that doesn't have one
nnoremap <Leader>4 :call CreateHeader()<CR>
" Toggle comment/uncomment current line
nnoremap <C-c> :call ToggleComment()<CR>
" Toggle comment/uncomment one or multiple selected lines
vnoremap <C-c> :call ToggleComment()<CR>gv
```
Otherwise, here's an explanation:
#### Headers:
1. First, declare your name in your vimrc: ```let g:my_name = "Your Name"```. This will be used in the headers.
2. Create a normal mode map that calls CreateHeader(). Use this to add a header to an existing file that doesn't already have one.
- ```nnoremap <Leader>4 :call CreateHeader()<CR>```
#### Comments:
1. Map a key that can be used in both normal and visual mode. I use ```<C-c>``` (control-c). Use it to call ToggleComment(). Create one mapping for normal mode, and one for visual mode:
- ```nnoremap<C-c> :call ToggleComment()<CR>```
- ```vnoremap<C-c> :call ToggleComment()<CR>gv``` (Add "gv" to the end of any visual map to stay in visual mode after execution)
- NOTE: When you press your shortcut key, the plugin will detect whether the line is commented out, and add/remove the comment character(s) from the beginning of the line and the end of the line if necessary. If you're in visual mode and have multiple lines selected, this action will be repeated for each line INDIVIDUALLY, so comment syntax will be inserted for each line in your selection that's not yet commented out, and it will be removed for each line in your section that is already commented out.
## CUSTOMIZE
- If you don't want headers to auto-insert in new or empty files, add this line to your vimrc: ```let g:auto_smart_header = 0```.
- To change the string preceding your name in the header, declare in vimrc: ```let g:headerstr_name = "Maintainer:     "```
- To change the string preceding the date in the header, declare: ```let g:headerstr_time = "Last Modified:  "```
- To change the formatting of the date, declare: ```let g:time_fmt = '%b %d, %Y'```
- Other possible date formats include: ```'%Y-%m-%d'```, ```'%m-%d-%Y'```, ```'%m/%d/%y'```, etc.

## DEMONSTRATION
Inside vim, type ```:new example.html``` and a new window window will open with the first 2 lines filled with a header:
```html
<!-- Maintainer:     Ryan Young -->
<!-- Last Modified:  11-05-21 -->
```
Or type ```:new example.py``` and a new window will open and be filled with the following:
```python
# Maintainer:     Ryan Young
# Last Modified:  11-05-21
```



