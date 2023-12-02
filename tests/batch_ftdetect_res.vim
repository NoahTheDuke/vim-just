" Disable pager
set nomore

bufdo  redir >> $OUTPUT | echo @% | set ft? | redir END

" Prevent stalling on 'Press ENTER or type command to continue'
call feedkeys("\<CR>")

qa
