foo: # comment
  uname -a

p1 := 'test'
p2 := canonicalize('..')
pdirname := replace_regex(p2, '/([^/]*)$', '$1')
param := semver_matches('0.1.1', '>=0.1.0')

@foo1 param1 param2="default test" +varparam='default': dependency1 (dependency2 p1 p2) (dependency3 param)
  echo many lines
  echo to follow
  echo {{quote(param1)}} {{quote(param2)}} {{varparam}}

dependency1:
  echo bar # comment

dependency2 firstparam=("abc\t" / 'def\t\"') secondparam=("""
  ghi
  jkl\tmno
""" + `echo pqr ' '`
+ uuid()):
  /bin/echo {{quote(firstparam)}}
  /bin/echo {{quote(secondparam)}}

dependency3 theparam=('a' + (if env_var_or_default('FOO', blake3_file(justfile())) == '1' { ' With Foo'} else { ' none ' + p1 / p2 }) / 'b'):
  echo {{quote(theparam)}}

dependency4:
	echo 'Is Dependency:' {{is_dependency()}}

test_dependency4: dependency4

test4: (dependency2 "123"
        + '456')
  echo Test

test5: (dependency2 "123"
        + '456') # comment
  echo Test

[no-cd]
runpwd:
	pwd

[private]
[confirm]
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

[
   private
  ,

    confirm
 ]
multiline-attr-no-continuations:
	/bin/true


[confirm("confirm2: Are you sure?")]
confirm2:
	python3 -c pass

[confirm (
  '''
  confirm3: Are you sure?''' \
)
 ]
confirm3:
	python3 -c pass

[confirm  \
  ( \
"
confirm4: Are you sure? [y/N]
>"
)]
confirm4:
	python3 -c pass


somevar := "1"
interp_with_func_with_arg foo:
	echo {{quote(foo)}}
	echo {{join('test',foo, `echo Bar`, somevar, "2")}}
	echo {{quote(blake3(foo+"-"))}}
	echo {{quote('x' + blake3(foo+"-"+ foo+'-'+foo) + foo+ 'y')}}
	echo {{quote(if foo == '123' { '321' } else { 'foo bar' } )}}

interp_with_conditional foo:
	echo {{if foo != 'foo' { quote(foo) } else { foo / foo } }}

[no-quiet]
loud:
	echo LOUD

hex_digits_all:
	echo {{HEXUPPER + replace_regex(HEXLOWER, '\d+', "")}}

[confirm(x"Run this recipe in $PWD ?")]
confirm_shell_expanded:
	echo {{x"Running in $PWD"}}

[group('foo group')]
grouped1:
	echo 'grouped'

# An undocumented recipe
[doc]
not_documented:
	echo foo

[doc('''
  A very documented recipe.
  This documentation comment spans multiple lines.
''')]
long_doc:
	echo foo foo

[positional-arguments]
positional *args:
	echo "$@"

[group: 'foo group']
attr-colon1:
	echo foo

[group  :  \
  \
 "foo group"
]
attr-colon2:
	echo foo

[
  doc:
    "Documentation",

  group:'foo group' ]
attr-colon3:
	echo foo

[doc: x"echo value of $$HOME: $HOME"]
attr-colon-shell-expanded-string:
	echo "$HOME"

[extension: '.py']
ext:
	#!/usr/bin/env python3
	import sys
	print(sys.argv)

styles:
	#!/bin/bash
	echo "{{GREEN}}Green{{NORMAL}}"
	echo '{{BLUE}}{{BOLD}}Bold Blue{{NORMAL}}'
	echo {{UNDERLINE}}{{MAGENTA}}Magenta underlined text{{NORMAL}}
	echo "{{style('command')}}echo command{{NORMAL}}"
	echo {{quote(style('command') + 'echo command' + NORMAL)}} >&2

[working-directory('../..')]
attr-working-directory:
	pwd
	ls -lA
