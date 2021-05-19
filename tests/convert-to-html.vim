set nobackup         " don't save backup files
set noswapfile       " don't create swap files
set nowritebackup    " don't create backup files while editing
set viminfofile=NONE " don't create .viminfo files

" edit the input justfile
edit $CASE

" convert justfile to HTML
TOhtml

" write HTML to output
w! $OUTPUT

" quit!
qa!
