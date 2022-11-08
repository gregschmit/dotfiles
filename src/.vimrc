function! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfunction

" Adjust this if your Vim/OS version is different.
call SourceIfExists("/usr/local/share/vim/vim90/defaults.vim")

set colorcolumn=80
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
