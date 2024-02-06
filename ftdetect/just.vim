" Vim filetype plugin
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just.git
" Last Change:	2023 Dec 03
au BufNewFile,BufRead \c{,.}justfile,\c*.just,\c*.justfile  setfiletype just
au BufNewFile,BufRead *  if getline(1) =~# '\v^#!//@!%(\w|-|//@!)*/%(env%(\s+-S)?\s+)?just\A' | setfiletype just | endif
