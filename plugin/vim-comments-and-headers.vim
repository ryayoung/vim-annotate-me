" Maintainer:     Ryan Young
" Last Modified:  Nov 05, 2021

let g:my_name = get(g:, 'my_name', '<Name goes here> (declare "g:my_name =" in vimrc)') "sets name variable if not already declared in vimrc
let g:headerstr_name = get(g:, 'headerstr_name', 'Maintainer:     ' . g:my_name)
let g:headerstr_time = get(g:, 'headerstr_time', 'Last Modified:  ')
let g:time_fmt = get(g:, 'time_fmt', '%b %d, %Y')
let g:cur_time = strftime(g:time_fmt)

let g:comment_start = get(g:, 'comment_start', '')
let g:comment_end = get(g:, 'comment_end', '')
let g:comment_start_esc = get(g:, 'comment_start_esc', '')
let g:comment_end_esc = get(g:, 'comment_end_esc', '')

if has_key(g:comments, &filetype) == 1
    let g:comment_start = g:comments[&filetype].start
    let g:comment_end = g:comments[&filetype].end
endif

" other events to mess around with: au BufNewFile,BufRead,FocusGained,BufEnter,WinEnter,FileType,FileWritePre,BufWritePre,BufWritePost * call SetCommentVars(&filetype)
au BufEnter * call SetCommentVars(&filetype) | call CreateFirstHeader()
fun! SetCommentVars(filetype)
    if has_key(g:comments, a:filetype) == 1
        let g:comment_start = g:comments[a:filetype].start
        let g:comment_end = g:comments[a:filetype].end
        call SetCommentVarsEscaped()
    else
        let g:comment_start = ''
        let g:comment_end = ''
        let g:comment_start_esc = ''
        let g:comment_end_esc = ''
        echom "NOTICE: Comment string unknown for " . &filetype " files. Go to /comment-string-data.vim"
    endif
endfun

fun! SetCommentVarsEscaped()
    " Create an escaped version of start comment and end comment
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
    let g:auto_smart_header = get(g:, 'auto_smart_header', '1')
    if g:auto_smart_header == 0
        return
    elseif line("$") == 1 && match(getline('.'), "^\\s*$") == 0 && &filetype != "" && &filetype != "csv"
        call CreateHeader()
        exe "normal! jo"
    endif
endfun

fun! CreateHeader()
    let l:save_cursor = getcurpos()
    let l:end = ""
    if g:comment_end != ""
        let l:end = " " . g:comment_end
    endif
    let l:space = " "
    if g:comment_start == ""
        let l:space = ""
    endif
    call setpos('.',[0,1,1,0])
    exe "normal! O"
    exe "normal! O"
    call setline(1, g:comment_start . l:space . g:headerstr_name . l:end)
    call setline(2, g:comment_start . l:space . g:headerstr_time . g:cur_time . l:end)
    call setpos('.', l:save_cursor)
endfun

autocmd BufWritePre,FileWritePre * call UpdateLastModified()
fun! UpdateLastModified()
    if &modified == 0 "Only update if changes have been made
        return
    endif
    let save_cursor = getcurpos()
    let end = ""
    if g:comment_end_esc != ""
        let end = " " . g:comment_end_esc
    endif
    let line = search(g:comment_start . " " . g:headerstr_time, "w")
    if line != 0 
        exe line . "g/" . g:headerstr_time . "/s/.*/" . g:comment_start_esc . " " . g:headerstr_time . g:cur_time . end
    endif

    call setpos('.', save_cursor)
endfun

fun! ToggleComment()
    if len(g:comment_start) > 0
        let l:line = getline('.')
        if l:line[0:len(g:comment_start)] == g:comment_start . ' '
            call RemoveComment(" ")
            echo "COMMENT OFF"
        elseif l:line[0:len(g:comment_start)-1] == g:comment_start
            call RemoveComment("")
            echo "COMMENT OFF"
        else
            call InsertComment()
            echo "COMMENT ON"
        endif
    endif
endfun

fun! InsertComment()
    let l:end = ""
    if g:comment_end != ""
        let l:end = " " . g:comment_end
    endif
    let l:current_line = getline('.')
    call setline('.', g:comment_start_esc . " " . l:current_line . l:end)
endfun

fun! RemoveComment(space)
    let l:end = ""
    if g:comment_end != ""
        let l:end = " " . g:comment_end
    endif
    let l:current_line = getline('.')

    if a:space == " "
        call setline('.', l:current_line[len(g:comment_start)+1:-1])
    elseif a:space == ""
        call setline('.', l:current_line[len(g:comment_start):-1])
    endif

    let l:current_line = getline('.')

    if getline('.')[-(len(g:comment_end)+1):-1] == " " . g:comment_end
        call setline('.', l:current_line[0:-(len(g:comment_end)+2)])
    endif

endfun



