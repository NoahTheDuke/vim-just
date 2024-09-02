" Disable pager
set nomore

bufdo  redir >> $OUTPUT | echo @% | set ft? | redir END

qa
