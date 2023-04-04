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

somevar := "1"
interp_with_func_with_arg foo:
	echo {{quote(foo)}}
	echo {{join('test',foo, `echo Bar`, somevar, "2")}}
	echo {{quote(sha256(foo+"-"))}}
	echo {{quote('x' + sha256(foo+"-"+ foo+'-'+foo) + foo+ 'y')}}
	echo {{quote(if foo == '123' { '321' } else { 'foo bar' } )}}
