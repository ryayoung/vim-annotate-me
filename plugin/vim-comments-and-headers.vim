" Maintainer:     Ryan Young
" Last Modified:  Nov 07, 2021

" Vim-Comments-and-Headers Plugin.
" See the README.md for an explanation of this stuff

" Feature to add: Allow users to define a license in vimrc (default MIT) and
" with a single keystroke insert the license in their file.
" antoyo/vim-licenses is the kind of functionality I'm looking for.

" USER INTERACTION:-----------------------------------------------------------
" Declare maps, if not set already by user
" 1. Comment Line in normal mode
if !hasmapto('ToggleComment()', 'n')
    nnoremap <silent> <C-c> :call ToggleComment()<CR>
endif
" 2. Comment Line in visual mode
if !hasmapto('ToggleComment()', 'v')
    vnoremap <silent> <C-c> :call ToggleComment()<CR>gv
endif
" 3. Create header at the top of the file with name and date
if !hasmapto('ToggleHeader()', 'n')
    nnoremap <silent> <Leader>z :call ToggleHeader()<CR>
endif

" GLOBAL VARIABLES:-----------------------------------------------------------
" These 'get(g:' commands will set vars to a default if they aren't already
" declared by user in their config
let g:my_name = get(g:, 'my_name', '<Name> (declare "g:my_name =" in vimrc)')
let g:headerstr_name=get(g:, 'headerstr_name', 'Maintainer:     ' . g:my_name)
let g:headerstr_time = get(g:, 'headerstr_time', 'Last Modified:  ')
let g:time_fmt = get(g:, 'time_fmt', '%b %d, %Y')
let g:cur_time = strftime(g:time_fmt) " Current time in declared format
let g:comment = ['"',''] " This will be the array to store comment vars
let g:comment_start = g:comment[0]
let g:comment_end = g:comment[1]

" Every action the plugin does automatically can be disabled by the user with:
let g:auto_header = get(g:, 'auto_header', '1') " Auto headers in new files?
let g:auto_update_date = get(g:, 'auto_update_date', '1') " Update date when saving
let g:auto_html_setup = get(g:, 'auto_html_setup', '1')
let g:auto_php_setup = get(g:, 'auto_php_setup', '1')

" ALTERNATE COMMENT SYNTAX:---------------------------------------------------
" Here is the comment syntax for most languages: https://rosettacode.org/wiki/Comments#Go

" Vim has great syntax highlighting, so it usually knows if a line of code is
" commented out. BUT it has terrible inconsistency in what gets stored in the
" &commentstring option for each filetype, so we have to correct for that.

" Here are the correct comment delimiters for filetypes where Vim provides
" incorrect values, or values that we want to change. Please, if you find more
" filetypes with incorrect comment delimiters provided 
" by vim, let me know: <yungryy@gmail.com>
let g:alternate_comments = {
    \ 'vb':         {'start': "'",      'end': ''},
    \ 'lss':        {'start': "'",      'end': ''},
    \ 'sql':        {'start': '--',     'end': ''},
    \ 'abap':       {'start': '"',      'end': ''},
    \ 'st':         {'start': '"',      'end': '"'},
    \ 'moo':        {'start': '"',      'end': '";'},
    \ 'pascal':     {'start': '(*',     'end': '*)'},
    \ 'xquery':     {'start': '(:',     'end': ':)'},
    \ 'ps1xml':     {'start': '<!--',   'end': '-->'},
    \ 'sas':        {'start': '/*',     'end': '*/'},
    \ 'pli':        {'start': '/*',     'end': '*/'},
    \ 'rexx':       {'start': '/*',     'end': '*/'},
    \ 'inform':     {'start': '[',      'end': ']'},
    \ 'lprolog':    {'start': '%',      'end': ''},
    \ 'logtalk':    {'start': '%',      'end': ''},
    \ 'postscr':    {'start': '%',      'end': ''},
    \ 'expect':     {'start': '#',      'end': ''},
    \ 'icon':       {'start': '#',      'end': ''},
    \ 'maple':      {'start': '#',      'end': ''},
    \ 'cpp':        {'start': '//',     'end': ''},
    \ 'php':        {'start': '//',     'end': ''},
    \ 'vhdl':       {'start': '--',     'end': ''},
    \ 'sather':     {'start': '--',     'end': ''},
    \ 'clojure':    {'start': ';;',     'end': ''},
    \ 'simula':     {'start': 'COMMENT','end': ''},
    \ 'tpp':        {'start': '--##',   'end': ''},
    \ 'text':       {'start': '',       'end': ''},
    \ 'help':       {'start': '',       'end': ''},
    \ 'custom':     {'start': '',       'end': ''},
    \ '':           {'start': '',       'end': ''}
    \ }


" AUTO COMMANDS:--------------------------------------------------------------
" Every time we enter a buffer, set the global comment strings based on its
" filetype, and see if we need to auto-generate a header
au BufEnter * call SetCommentVars() | call CreateFirstHeader()

" Try to update the date each time we save a file
au BufWritePre,FileWritePre * call UpdateHeaderDate()

" COMMENTS:-------------------------------------------------------------------

" Set our global comment strings
fun! SetCommentVars()
    " This function is designed so that the g:comment array will ALWAYS be of
    " length 2, even if there is no comment syntax for the current language,
    " or if splitting Vim's commentstring returns more than 2 values
    let g:comment = ['','']
    " If this filetype exists in our dictionary of alternate comment strings,
    " set our comment to the matching values
    if has_key(g:alternate_comments, &filetype) == 1
        let g:comment[0] = g:alternate_comments[&filetype].start
        let g:comment[1] = g:alternate_comments[&filetype].end

    " Else, use Vim's commentstring
    elseif !has_key(g:alternate_comments, &filetype) == 1
        let l:commentstring = split(&commentstring, "%s")
        " If commentstring has more than 2 values, just choose the first 2
        if len(l:commentstring) > 0
            let g:comment[0] = trim(l:commentstring[0], " ", 0)
        endif
        if len(l:commentstring) > 1
            let g:comment[1] = trim(l:commentstring[1], " ", 0)
        endif
    endif

    let g:comment_start = g:comment[0]
    let g:comment_end = g:comment[1]

endfun

fun! ToggleComment()
    " If the current language uses comments (i.e. it's NOT a txt file)
    if len(g:comment_start) > 0 
        " Get the current line without trailing whitespace at end
        let l:line = trim(getline('.'), " \t", 2)
        " Save amount of space from start of line to the start comment:
        let l:indent = GetWhitespace(l:line, 1)
        " Line now = original, minus beginning and ending whitespace
        let l:line = l:line[len(l:indent):-1]
        " If the code HAS been commented out
        if l:line[0:len(g:comment_start)-1] == g:comment_start
            " Get the whitespace between starting comment and the code
            let l:space_between = GetWhitespace(l:line[len(g:comment_start):-1], 1)
            call RemoveComment(l:space_between, l:line, l:indent)
        " The code has NOT been commented out
        else
            call InsertComment(l:line, l:indent)
        endif
    endif
endfun

fun! InsertComment(line, indent)
    " Space at the end depends on whether our language uses an end comment
    let l:end = ""
    if g:comment_end != ""
        let l:end = " " . g:comment_end
    endif
    " Set the line to its original value, wrapped in comment syntax.
    call setline('.', a:indent . g:comment_start . " " . a:line . l:end)
endfun

fun! RemoveComment(space_between, line, indent)
    " Line: code 
    let l:end = ""
    " If this language requires an end comment, we need to check if one exists
    " and then remove it.
    if g:comment_end != ""
        " Make sure the commented line actually has a correct ending comment.
        " A correct ending comment may have zero or many spaces before it, and
        " zero or many spaces after it. Spaces at the end of the line were
        " already removed by ToggleComment(), but we need to determine spaces
        " between code and end comment.
        if a:line[0-len(g:comment_end):-1] == g:comment_end
            let l:line_without_end_comment = a:line[0:-1-len(g:comment_end)]
            let l:space_before_end = GetWhitespace(l:line_without_end_comment, 2)
            let l:end = l:space_before_end . g:comment_end
        endif
    endif

    " Our new line = indent + code. It is free of any unnecessary spaces
    let l:index_of_code_start = len(g:comment_start)+len(a:space_between)
    let l:index_of_code_end = -1 - len(l:end)
    call setline('.', a:indent . a:line[l:index_of_code_start : l:index_of_code_end])
endfun

fun! GetWhitespace(string, type)
    " The opposite of trim. Get whitespace instead of remove it.
    " Type 1: Get whitespace at beginning of line
    " Type 2: Get whitespace from end of line
    if a:type == 1 && a:string[0] == " " 
        return a:string[0:len(a:string) - len(trim(a:string, " \t", a:type))-1]
    elseif a:type == 2
        return a:string[len(trim(a:string, " \t", a:type)):-1]
    else
        " Using type 1, and first char in string is not empty, return ''
        return ""
    endif
endfun

" HEADERS:--------------------------------------------------------------------

fun! CreateFirstHeader()
    if g:auto_header == 0
        " User has disabled this feature
        return
    " If there is only a single line in the file, AND that line is empty,
    " AND the filetype is known, AND the file is not type CSV
    elseif line("$") == 1 && match(getline('.'), "^\\s*$") == 0 
                \ && &filetype != "" && &filetype != "csv"
        call ToggleHeader()
        exe "normal! j"
        call SpecialFileSetup()
    endif
endfun

fun! ToggleHeader()
    " Save cursor position
    let l:cursor = getcurpos()
    " If we're commenting out the header (i.e. it's not a txt file), surround
    " the header with spaces. Otherwise, don't use spaces.
    let l:end = ""
    if g:comment_end != ""
        let l:end = " " . g:comment_end
    endif
    let l:space = " "
    if g:comment_start == ""
        let l:space = ""
    endif
    " Only replace lines if we're ABSOLUTELY SURE they are headers
    let l:name_line = search(g:comment_start . l:space . g:headerstr_name, "w")
    let l:date_line = search(g:comment_start . l:space . g:headerstr_time, "w")
    " Name can be on line 1 or 2, date can be on 2 or 3. This is because some
    " languages such as PHP require an opening tag on the first line
    if (l:name_line == 1 || l:name_line == 2) && (l:date_line == 2 || l:date_line == 3)
        call setpos('.',[0,l:name_line,1,0])
        exe "normal! dj"
        " To maintain RELATIVE cursor position, place the cursor 2 lines
        " higher than its original position
        call setpos('.', [l:cursor[0],l:cursor[1]-2,l:cursor[2],l:cursor[3]])

    " No header found with 100% certainty, so add a new one just to be safe
    else
        " At which line will we place the file?
        let l:hdr_location = 1
        " Some languages require code to be wrapped in tags, so the first line
        " of a php file, for example, should be '<?php'
        if &filetype == 'php' && getline(1) == "<?php"
            let l:hdr_location = 2
        endif
        call setpos('.',[0,l:hdr_location,1,0])
        exe "normal! O"
        exe "normal! O"
        call setline(l:hdr_location, g:comment_start . l:space . g:headerstr_name . l:end)
        call setline(l:hdr_location+1, g:comment_start . l:space . g:headerstr_time . g:cur_time . l:end)
        " To maintain RELATIVE cursor position, place the cursor 2 lines lower
        " than its original position
        call setpos('.', [l:cursor[0],l:cursor[1]+2,l:cursor[2],l:cursor[3]])
    endif
endfun

" Feature to add soon: Currently, if we try to update a date and can't
" find one, we do nothing. However, what if the user changes their string for
" the date title, and changes the format for the date in their vimrc. Then,
" the date line will look totally different from what we're trying to find, so
" we end up not updating it. Here's a strategy: The one thing that WILL remain
" constant is the user's name. So, if we can't find a date line, look for the
" user's name in the first line. If found, then add a new line with the
" updated date, and let the user delete the old date line on their own.
fun! UpdateHeaderDate()
    if g:auto_update_date == 0 
        " User has disabled this feature
        return
    elseif &modified == 0 
        " Don't update if the file is unchanged
        return
    else
        let save_cursor = getcurpos()
        " End of the line will be empty unless an end comment is required
        let end = ""
        if g:comment_end != ""
            let end = " " . g:comment_end
        endif
        " Put space before the content ONLY if a comment is required
        let l:space = " "
        if g:comment_start == ""
            let l:space = ""
        endif
        " Find the line where the date is
        let l:line_num = search(g:comment_start . l:space . g:headerstr_time, "w")
        " Only execute if a date header was found
        if l:line_num != 0 && l:line_num < 10
            " Fully replace the entire line with new content
            call setline(l:line_num, g:comment_start . l:space
                        \ . g:headerstr_time . g:cur_time . end )
        endif

        " Return cursor to it's absolute (not relative) position
        call setpos('.', save_cursor)
    endif
endfun

" EXTRA FILE CUSTOMIZATION:---------------------------------------------------
" For some filetypes, such as PHP or HTML, it's nice to have some extra setup

fun! SpecialFileSetup()
    if &filetype == "php" && g:auto_php_setup == 1
        exe "normal! ggO"
        call setline('.', "<?php")
        exe "normal! Go"
        call setline('.', "?>")
    endif
    if &filetype == 'html' && g:auto_html_setup == 1
        call InsertHtmlHeader()
    endif
endfun

fun! InsertHtmlHeader()
    exe "normal! G"
    let l:line = line('.')
    call setline(l:line+1, "<!DOCTYPE html>")
    call setline(l:line+2, '<html lang="en-US">')
    call setline(l:line+3, "  <head>")
    call setline(l:line+4, '    <link rel="stylesheet" href="">')
    call setline(l:line+5, '    <script src=""></script>')
    call setline(l:line+6, '    <meta charset="utf-8">')
    call setline(l:line+7, "  </head>")
    call setline(l:line+8, "  <body>")
    call setline(l:line+9, "    ")
    call setline(l:line+10, "  </body>")
    call setline(l:line+11, "</html>")
endfun
