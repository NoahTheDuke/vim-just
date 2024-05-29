" Vim filetype plugin
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just.git
" Last Change:	2024 Mar 03
au BufNewFile,BufRead \c{,*.}justfile,\c*.just  setfiletype just
au BufNewFile,BufRead *  if getline(1) =~# '\v^#!/%(\w|[-/])*/%(env%(\s+-S)?\s+)?just\A' | setfiletype just | endif
