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

other_export := '1'
export some_export := '0' + other_export

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

env_test_export:
	env | grep -F export