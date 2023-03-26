foo: # comment
  bar

foo2:
  bar # comment

[no-cd]
dopwd:
	pwd

[private]
[no-exit-message]
error:
	sh -c 'echo Exit 3;exit 3'

[ unix ]
[  macos,windows, linux ]
any:
	echo foo
