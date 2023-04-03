foo: # comment
  bar

foo2:
  bar # comment

[no-cd]
runpwd:
	pwd

[private]
[no-exit-message]
error:
	sh -c 'echo Exit 3;exit 3'

[ unix ]
[  macos,windows, linux ]
any:
	echo foo

[ private ,no-cd , unix]
[no-exit-message ]
runpwd_then_error:
	pwd
	sh -c 'exit 2'
	echo unreachable
