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

test:
	echo {{something}}{{testing}}

test2:
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

functions2 cpus = num_cpus() foo = env('FOO', uuid()) :
	echo '{{foo}}:x{{cpus}}'

env_test_export:
	env | grep -F -i export
alias printenv:=env_test_export
