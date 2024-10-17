# This recipe is at the start of this file because `just` inserts extra lines to make shebang script line numbers match the corresponding justfile line numbers.
skip-all-whitespace-lines-shebang:
	#!/bin/bash

  
 	
	echo -e -n '\033[1;47;30m'
	cat "$0"
	echo -e -n '\033[0m'

set ignore-comments

raw := '''
  it's two lines \
'''

something := """
  "T E " \
  "S T " \
"""

testing := ```
  foo=`echo '  testing  '`;echo $foo  123
```

nospace:='ABCabc'

other_export := '1'
export some_export := '0' + other_export
export SOME_EXPORT2:='1'

valid_uuid := uuid( )

this_justfile := justfile	 ( 

  )

not_a_uuid_anymore := replace_regex  (
    uuid	(
  ), '-4([0-9A-Fa-f]{3})-'
, '_9${1}_'
)

conditional_without_indent := if env('SHELL') == '/bin/bash' {
valid_uuid + testing
} else { '' }

paren_without_indent := (
valid_uuid + testing
)

back2back_interpolations:
	echo {{something}}{{testing}}

interp_immediately_after_string:
	#!/usr/bin/env python3
	print(''{{quote(something)}}''.split("T"))

curly_braces_3:
	echo 'Four {{{{{{{{{{"""\
Opening """ + 'Curly ' + "Braces"}}!'
	echo }}

line_continuation:
	echo 'This starts with tabs \
	  but continues with tabs and spaces'
	echo 123 456 \
	  789

line_continuation2:
  echo "This starts with spaces \
  	but continues with spaces and tabs"
  echo 987 654 \
  	321

mismatched_but_escaped_quotes:
	echo it\'s a single apostrophe
	echo "\"single escaped quote"
	echo "string \\" ended there

shebang_mixed_indentation:
	#!/usr/bin/env python3
	if True:
	  print('tab indent followed by spaces is allowed in shebang recipe')

shebang_recipes_dont_do_line_prefixes:
	#!/bin/bash
	@foo

multiline-non-paren-final-param param0=valid_uuid *$PARAM="""
  foo

""":
	echo {{param0}}
	env | grep -F PARAM

immediate-comment:#this is valid
	echo comment

spaced_params param1  =  valid_uuid  * param2	=	"x" :
	echo {{param1}} {{param2}}

spaced_params2 param1  =  valid_uuid  + $ ENV_PARAM2  = 'exported environment variable value':
	echo {{param1}}
	env | grep -F PARAM2

spaced_paren_param param1 = (valid_uuid + valid_uuid):
	echo {{param1}}

spaced_paren_param2 param=(valid_uuid ) :
	echo {{param}}

invoke shell:
	{{shell}}

multi count=num_cpus():
	seq -s ' ' 1 {{count}}

functions2 cpus = num_cpus() foo = env('FOO', just_pid()) :
	echo '{{foo}}:x{{cpus}}'

env_test_export:
	env | grep -F -i export
alias printenv:=env_test_export

parenthesized_dep_param: (multi ('1' + '0'))

parenthesized_dep_param2 p: (invoke \
  (p + " -c 'echo 123'") \
)

parenthesized_dep_param3: (multi \
  ( '1' + '0' ) \
) (
functions2 valid_uuid) \
( 

	\

  unexport
  this_justfile
)

skip-all-whitespace-lines1:
    echo '111'

    echo '222'

skip-all-whitespace-lines2:
	echo start
	

  	
	echo end

triple-quoted-multiline-interp:
	echo {{quote("""
[package]
name = "foo"
edition = "2021"

[dependencies]
""")}} > {{quote(cache_directory() / 'Cargo.toml-' + valid_uuid)}}

not-shell-expanded-string fix: (functions2 fix'$HOME')
not-shell-expanded-string2 _-x: (functions2 _-x"$HOME")

unexport PARAM \
:
	-env | grep -P {{quote(PARAM)}}

ignored-comments-in-recipe foo='Foo':
	echo recipe
	# echo {{ foo }} {{{{test \
	echo recipe

# documented recipe 1
documented1:
# documented recipe 2
documented2:
