runtime defaults.vim

set colorcolumn=80,100
set number
set relativenumber
set showcmd
set cursorline
set wildmenu
set showmatch

" Overrides
autocmd FileType c setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType sh setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType systemverilog setlocal expandtab
autocmd BufNewFile,BufRead *.gitcommit setlocal filetype=gitcommit
autocmd BufNewFile,BufRead *.conf setfiletype conf
