set nobackup               " don't save backup files
set noswapfile             " don't create swap files
set nowritebackup          " don't create backup files while editing
set viminfofile=NONE       " don't create .viminfo files
let g:html_no_progress = 1 " don't show a progress bar

" define a color for every default syntax class
hi Boolean        ctermfg=7*
hi Character      ctermfg=7*
hi Comment        ctermfg=7*
hi Conditional    ctermfg=7*
hi Constant       ctermfg=7*
hi Debug          ctermfg=7*
hi Define         ctermfg=7*
hi Delimiter      ctermfg=7*
hi Error          ctermfg=7*
hi Exception      ctermfg=7*
hi Float          ctermfg=7*
hi Function       ctermfg=7*
hi Identifier     ctermfg=7*
hi Ignore         ctermfg=7*
hi Include        ctermfg=7*
hi Keyword        ctermfg=7*
hi Label          ctermfg=7*
hi Macro          ctermfg=7*
hi Normal         ctermfg=7*
hi Number         ctermfg=7*
hi Operator       ctermfg=7*
hi PreCondit      ctermfg=7*
hi PreProc        ctermfg=7*
hi Repeat         ctermfg=7*
hi Special        ctermfg=7*
hi SpecialChar    ctermfg=7*
hi SpecialComment ctermfg=7*
hi Statement      ctermfg=7*
hi StorageClass   ctermfg=7*
hi String         ctermfg=7*
hi Tag            ctermfg=7*
hi Todo           ctermfg=7*
hi Type           ctermfg=7*
hi Typedef        ctermfg=7*
hi Underlined     ctermfg=7*

" convert justfile to HTML
TOhtml

" write HTML to output
w! $OUTPUT

" quit!
qa!
