" Vim filetype plugin
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just.git
" Last Change:	2021 Aug 26
autocmd BufNewFile,BufRead \cjustfile,.justfile,*.just setfiletype just
