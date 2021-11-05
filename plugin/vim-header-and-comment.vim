" Maintainer:     Ryan Young
" Last Modified:  11-04-21

" Here is the comment syntax for most languages: https://rosettacode.org/wiki/Comments#Go

" Source comment vars from other file
source ~\vimfiles\plugin\set-comment-strings.vim

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
        echom "NOTICE: Comment variable known for filetype " . &filetype
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
    let g:name = get(g:, 'name', '<Name goes here> (declare "g:name =" in vimrc)') "sets name variable if not already declared in vimrc
    let l:save_cursor = getcurpos()
    let title1 = "Maintainer:     " . g:name
    let title2 = "Last Modified:  "
    let time = strftime("%m-%d-%y")
    let end = ""
    if g:comment_end != ""
        let end = " " . g:comment_end
    endif
    execute "normal! ggO" | execute "normal! cc" . g:comment_start . " " . title1 . end
    execute "normal! o" | execute "normal! cc" . g:comment_start . " " . title2 . time . end
    call setpos('.', l:save_cursor)
endfun

autocmd BufWritePre,FileWritePre * call UpdateLastModified()
fun! UpdateLastModified()
    if &modified == 0 "Only update if changes have been made
        return
    endif
    let save_cursor = getcurpos()
    let title = "Last Modified:  "
    let time = strftime("%m-%d-%y")
    let end = ""
    if g:comment_end_esc != ""
        let end = " " . g:comment_end_esc
    endif
    let line = search(g:comment_start . " " . title . "..-..-..", "w")
    if line != 0 
        exe line . "g/" . title . "/s/.*/" . g:comment_start_esc . " " . title . time . end
    endif

    call setpos('.', save_cursor)
endfun

fun! ToggleComment()
    if len(g:comment_start) > 0
        let l:line = getline('.')
        if l:line[0:len(g:comment_start)] == g:comment_start . ' '
            call RemoveComment(" ")
        elseif l:line[0:len(g:comment_start)-1] == g:comment_start
            call RemoveComment("")
        else
            call InsertComment()
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



