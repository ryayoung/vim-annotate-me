# vim-annotate-me
Vim plugin

1. **Toggle** comment/uncomment one or multiple lines of code at a time by pressing **```T```**.
2. Recognizes your filetype and will comment/uncomment according to that syntax. Added support for most languages that Vim doesn't. Works for languages with double-ended comment strings. (Ex: **```<!-- some html stuff -->```**).
3. Automatically creates headers (name & today's date) at the top of any new document you create, or any empty document that you open, with proper comment syntax based on your filetype.
4. Lets you toggle the current file's header on/off with a single keypress, without disrupting your code, and without moving your cursor from its relative position.
5. As soon as you write/save a file that HAS been modified, the header (if one exists) will be updated with the current date.
6. The header format is fully customizeable, including the format of the current date. If you change the date format in your vimrc, the old dates in your previous files will automatically update with the new format once you save/write to them again.

## INSTALLATION
1. If using Plug as your plugin manager, paste into the plugin section of your ```vimrc```:
```vim
Plug 'ryayoung/vim-annotate-me'
```
2. Run **```:PlugInstall```** after saving and re-opening Vim.
## HOW TO USE
- **Declare your name in ```vimrc```: (this will be used in headers)**
```vim
let g:my_name = "Your Name"
```
- **Commented Text:** Toggle using **```T```** in normal or visual mode, on one or multiple lines.
- **Display Header:** Toggle using **```<Leader>T```**. If you haven't set leader key yet, use **```\T```**.
## NOTES:
#### Comments: 
- When you press your shortcut key, the plugin will detect whether the line is commented out, and add/remove the comment character(s) from the beginning of the line and the end of the line if necessary.
- If you're in visual mode and have multiple lines selected, this action will be repeated for each line INDIVIDUALLY, so comment syntax will be inserted for each line in your selection that's not yet commented out, and it will be removed for each line in your section that is already commented out.
#### Headers: 
- A header will be automatically inserted when you a.) create and give a name to a new file inside vim, or b.) open a completely empty file.
- Header date will auto-update when you save/write to a file that *has been modified*.
- When toggling the header on/off and auto-updating date, your cursor will maintain its relative position.
## CUSTOMIZE
#### If you don't want headers to auto-insert in new or empty files, add this line to your vimrc: 
```vim
let g:auto_header = 0
```
#### If you don't want the header date to auto-update when saving a modified file, paste in vimrc:
```vim
let g:auto_update_date = 0
```
#### To change the string preceding your name in the header, declare in your vimrc: 
```vim
let g:headerstr_name = "Maintainer:     "
```
#### To change the string preceding the date in the header, declare in your vimrc:
```vim
let g:headerstr_time = "Last Modified:  "
```
#### To change the formatting of the date, declare in your vimrc:
```vim
let g:time_fmt = '%b %d, %Y'
```
- Other date formats: **```'%Y-%m-%d'```, ```'%m-%d-%Y'```, ```'%m/%d/%y'```,** etc.
#### Don't want to give up Vim's built-in ```T``` function? Paste the following into ```vimrc``` to use ```<C-C>``` (Ctrl-c) instead.
```vim
" Comment in normal mode
nnoremap <silent> <C-c> :call ToggleComment()<CR>
" Comment in visual mode
vnoremap <silent> <C-c> :call ToggleComment()<CR>gv
" Toggle header in normal mode
nnoremap <silent> <Leader>z :call ToggleHeader()<CR>
```

## DEMONSTRATION
Here is what a newly created file will look like in a few different languages:
1. Python: **```:new example.py```**
```python
# Maintainer:     Ryan Young
# Last Modified:  Nov 09, 2021
```
2. PHP: **```:new example.php```**
```php
<?php
// Maintainer:     Ryan Young
// Last Modified:  Nov 09, 2021
?>
```
3. HTML: **```:new example.html```**
```html
<!-- Maintainer:     Ryan Young -->
<!-- Last Modified:  Nov 09, 2021 -->
<!DOCTYPE html>
<html lang="en-US">
  <head>
    <link rel="stylesheet" href="">
    <script src="" async></script>
    <meta charset="utf-8">
  </head>
  <body>
    
  </body>
</html>
```
## ISSUES
- Languages which require indentations in front of comments, such as COBOL, are not fully supported: You'll still have the same functionality, but the required indents will NOT be inserted for you.


