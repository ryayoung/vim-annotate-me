" Maintainer:     Ryan Young
" Last Modified:  Nov 06, 2021

" Vim-Comments-and-Headers Plugin.
" See the README.md for an explanation of this stuff

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

" These 'get(g:' commands will set variables to a default unless they are already declared by user
let g:my_name = get(g:, 'my_name', '<Name goes here> (declare "g:my_name =" in vimrc)')
let g:headerstr_name = get(g:, 'headerstr_name', 'Maintainer:     ' . g:my_name)
let g:headerstr_time = get(g:, 'headerstr_time', 'Last Modified:  ')
let g:time_fmt = get(g:, 'time_fmt', '%b %d, %Y')
let g:cur_time = strftime(g:time_fmt)
let g:auto_header = get(g:, 'auto_header', '1')
let g:auto_update_date = get(g:, 'auto_update_date', '1')

let g:comment_start = get(g:, 'comment_start', '')
let g:comment_end = get(g:, 'comment_end', '')
let g:comment_start_esc = get(g:, 'comment_start_esc', '')
let g:comment_end_esc = get(g:, 'comment_end_esc', '')

" SET COMMENT VARS (better explained in SetCommentVars())
if has_key(g:comments, &filetype) == 1
    let g:comment_start = g:comments[&filetype].start
    let g:comment_end = g:comments[&filetype].end
endif

" other events to mess around with: au BufNewFile,BufRead,FocusGained,BufEnter,WinEnter,FileType,FileWritePre,BufWritePre,BufWritePost * call SetCommentVars(&filetype)

" Every time we enter a buffer, set the global comment strings based on its
" filetype, and see if we need to auto-generate a header
au BufEnter * call SetCommentVars(&filetype) | call CreateFirstHeader()
fun! SetCommentVars(filetype)
    " If this filetype exists in our dictionary of comment strings, then set
    " the comment string variables
    if has_key(g:comments, a:filetype) == 1
        let g:comment_start = g:comments[a:filetype].start
        let g:comment_end = g:comments[a:filetype].end
        call SetCommentVarsEscaped()

    " We haven't defined syntax for this filetype, so just set the variables
    " empty, and give the user a descriptive warning.
    else
        let g:comment_start = ''
        let g:comment_end = ''
        let g:comment_start_esc = ''
        let g:comment_end_esc = ''
        echom "NOTICE: Comment string unknown for " . &filetype " files. Go to /comment-string-data.vim"
    endif
endfun

fun! SetCommentVarsEscaped()
    " Create an escaped version of start comment and end comment. These will
    " be used in the grep command to update date header. (Yes, I know this is
    " a stupid way to do this. This will be fixed soon.)
    let l:com_start_split = split(g:comment_start, '\zs')
    let l:com_end_split = split(g:comment_end, '\zs')

    for i in range(0, len(l:com_start_split)-1)
        if l:com_start_split[i] == "/"
            let l:com_start_split[i] = '\' . l:com_start_split[i]
        endif
    endfor
    for i in range(0, len(l:com_end_split)-1)
        if l:com_end_split[i] == "/"
            let l:com_end_split[i] = '\' . l:com_end_split[i]
        endif
    endfor

    let g:comment_start_esc = join(l:com_start_split, "")
    let g:comment_end_esc = join(l:com_end_split, "")
endfun
call SetCommentVarsEscaped()

fun! CreateFirstHeader()
    if g:auto_header == 0
        " User has disabled this feature
        return
    " If the filetype is known, AND the file is empty, AND it's not a CSV:
    elseif line("$") == 1 && match(getline('.'), "^\\s*$") == 0 && &filetype != "" && &filetype != "csv"
        call ToggleHeader()
        exe "normal! jo"
    endif
endfun

fun! ToggleHeader()
    let l:save_cursor = getcurpos()
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
    if search(g:comment_start . l:space . g:headerstr_name, "w") == 1
                \ && search(g:comment_start . l:space . g:headerstr_time, "w") == 2
        call setpos('.',[0,1,1,0])
        exe "normal! dj"
        " To maintain RELATIVE cursor position, place the cursor 2 lines
        " higher than its original position
        call setpos('.', [l:save_cursor[0],l:save_cursor[1]-2,l:save_cursor[2],l:save_cursor[3]])

    " No header found with 100% certainty, so add a new one just to be safe
    else
        call setpos('.',[0,1,1,0])
        exe "normal! O"
        exe "normal! O"
        call setline(1, g:comment_start . l:space . g:headerstr_name . l:end)
        call setline(2, g:comment_start . l:space . g:headerstr_time . g:cur_time . l:end)
        " To maintain RELATIVE cursor position, place the cursor 2 lines lower
        " than its original position
        call setpos('.', [l:save_cursor[0],l:save_cursor[1]+2,l:save_cursor[2],l:save_cursor[3]])
    endif
endfun

autocmd BufWritePre,FileWritePre * call UpdateLastModified()
fun! UpdateLastModified()
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
        if g:comment_end_esc != ""
            let end = " " . g:comment_end_esc
        endif
        " Put space before the content ONLY if a comment is required
        let l:space = " "
        if g:comment_start == ""
            let l:space = ""
        endif
        " Find the line where the date is
        let line = search(g:comment_start . l:space . g:headerstr_time, "w")
        " Only execute if a date header was found
        if line != 0 
            " Fully replace the entire line with new content
            exe line . "g/" . g:headerstr_time . "/s/.*/" . g:comment_start_esc . l:space . g:headerstr_time . g:cur_time . end
        endif

        call setpos('.', save_cursor)
    endif
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
    call setline('.', a:indent . g:comment_start_esc . " " . a:line . l:end)
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




