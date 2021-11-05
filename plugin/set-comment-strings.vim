" Maintainer:     Ryan Young
" Last Modified:  11-04-21
let g:comments = {
    \ 'vb':         {'start': "'", 'end': ''},
    \ 'vim':        {'start': '"', 'end': ''},
    \ 'pascal':     {'start': '(*', 'end': '*)'},
    \ 'xhtml':      {'start': '<!--', 'end': '-->'},
    \ 'html':       {'start': '<!--', 'end': '-->'},
    \ 'xml':        {'start': '<!--', 'end': '-->'},
    \ 'css':        {'start': '/*', 'end': '*/'},
    \ 'c':          {'start': '/*', 'end': '*/'},
    \ 'typescript': {'start': '/*', 'end': '*/'},
    \ 'python':     {'start': '#', 'end': ''},
    \ 'ruby':       {'start': '#', 'end': ''},
    \ 'perl':       {'start': '#', 'end': ''},
    \ 'ps1':        {'start': '#', 'end': ''},
    \ 'cs':         {'start': '//', 'end': ''},
    \ 'go':         {'start': '//', 'end': ''},
    \ 'swift':      {'start': '//', 'end': ''},
    \ 'cpp':        {'start': '//', 'end': ''},
    \ 'php':        {'start': '//', 'end': ''},
    \ 'javascript': {'start': '//', 'end': ''},
    \ 'java':       {'start': '//', 'end': ''},
    \ 'rust':       {'start': '//', 'end': ''},
    \ 'scala':      {'start': '//', 'end': ''},
    \ 'kotlin':     {'start': '//', 'end': ''},
    \ 'sql':        {'start': '--', 'end': ''},
    \ 'haskell':    {'start': '--', 'end': ''},
    \ 'lua':        {'start': '--', 'end': ''},
    \ 'ada':        {'start': '--', 'end': ''},
    \ 'matlab':     {'start': '%', 'end': ''},
    \ 'help':       {'start': '', 'end': ''},
    \ '':           {'start': '', 'end': ''}
    \ }


" SYNTAX LIST NOTES: (file extension, filetype, comment syntax)
" vim   vim         "
" vb    vb          '
" inc   pascal      (* *)
" xhtml xhtml       
" html  html        <!-- -->
" xml   xml         <!-- -->
" css   css         /* */
" c     c           /* */
" ts    typescript  /* */
" py    python      #
" rb    ruby        #
" pl    perl        #
" ps1   ps1         #
" cs    cs          //
" go    go          //
" swift swift       //
" cpp   cpp         //
" php   php         //
" js    javascript  //
" java  java        //
" rs    rust        //
" scala scala       //
" kt    kotlin      //
" sql   sql         --
" hs    haskell     --
" lua   lua         --
" ada   ada         --
" m     matlab      %
" txt   text        none
" md    markdown    none

