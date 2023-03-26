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
