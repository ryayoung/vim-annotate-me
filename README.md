# vim-comments-and-headers

### This plugin does the following:
1. It lets you comment/uncomment one or multiple lines at a time with a shortcut of your choice. It recognizes your filetype and will comment/uncomment according to that syntax. This is especially useful in languages such as HTML, where comments must be closed at the end of the line (Ex: ```<!-- some html stuff -->```).
2. It automatically creates headers (name & today's date) at the top of any new document you create, or any empty document that you open, and comments out that header using correct syntax based on your filetype. Additionally, you can map a shortcut to add a header to an existing file that doesn't already have one.
3. As soon as you write/save a file that HAS been modified, the header (if one exists) will be updated with the current date.

## Installation
Insert ```Plug 'ryayoung/vim-comments-and-headers'``` in the plugin section of your ```vimrc```, if you're using Plug as your plugin manager. Run ```:PlugInstall``` after saving and re-opening Vim. If you use a different plugin manager, figure it out.
## How to Use
#### HEADERS:
1. Add the following line to your vimrc: ```let g:my_name = "Your Name"```. This will be used in the headers.
2. Create a normal mode map that calls CreateHeader(). Use this to add a header to an existing file that doesn't already have one.
- ```nnoremap <Leader>4 :call CreateHeader()<CR>```
#### COMMENTS:
1. Map a key that can be used in both normal and visual mode. I use ```<C-c>``` (control-c). Use it to call ToggleComment().
- ```nnoremap<C-c> :call ToggleComment()<CR>```
- ```vnoremap<C-c> :call ToggleComment()<CR>gv``` (Add "gv" to the end of any visual map to stay in visual mode after execution)
## CUSTOMIZE
- If you don't want headers to auto-insert in new or empty files, add this line to your vimrc: ```let g:auto_smart_header = 0```.

