 !include not-at-beginning-of-line.just

mod -invalid-mod

set shell

bash := 'bash'
c := '-c'
set shell := [bash, c]

invalid_escapes := "\q \u{} \u{foo}\u{1234123} \u1234"
invalid_escapes_shell_expanded := x"${foo:-z\u{zzz}z}"

# export is only valid when prefixing an assignment
# just thinks the following line is a malformed attempt to start a recipe called "export"
export FOO

	(the next line is not a recipe body)...
	this text should not be highlighted

badfunc5 := num_cpus(\)

not_a_recipe_name #comment:
	not a recipe body

nonexistant_func := blahuuid()
nonexistant_func2 := blah_replace_regex('foo', '([^o])', '$1')

invalid_recipe_body:
 	  echo 'My indentation mixes spaces and tabs!'
	 echo 'My indentation mixes tabs and spaces!'
 	echo 'Mixing spaces and tabs again.'

invalid_recipe_body2:
	echo This line is valid
	  echo but this one is not
invalid_recipe_body3:
	echo "valid again
	  not valid"
invalid_recipe_body4:
  echo 'valid again
  	not valid'

not_a_recipe_start
	not a recipe body
bad_but_not_mixed_indentation:
	echo 'tab indent'
        echo 'space indent'
bad_but_not_mixed_indentation_shebang:
  #!/bin/bash
  echo 'space indent, same as first line'
    echo 'acceptable space indent'
	echo 'tab indent'

bad_curly_braces:
	echo {{{Odd number of opening curly braces is an error.}}
	echo {{{{{Odd number of opening curly braces is an error.}}
	echo {{{{{{{Odd number of opening curly braces is an error.}}
	echo {{{{{{{{{Odd number of opening curly braces is an error.}}
	echo '{{{Odd number of opening curly braces is an error.}}'
	echo '{{{{{Odd number of opening curly braces is an error.}}'
	echo '{{{{{{{Odd number of opening curly braces is an error.}}'
	echo '{{{{{{{{{Odd number of opening curly braces is an error.}}'
	echo {{{{{{{Odd number of opening curly braces is an error.}}}}}
	echo "{{{{{{{{{Odd number of opening curly braces is an error.}}}}}"

early-interpolation-close foo:
  echo {{ if foo == "bar" { "hello" } else { "goodbye" }}}
other-recipe:
	echo interpolation ended in last recipe

variadic-env-wrong-order1 param0 $*PARAM:
	env
variadic-env-wrong-order2 $+PARAM="1":
	env
variadic-env-wrong-order-with-whitespace $  *  PARAM:
	env

non-default-param-after-default param0='value' param1:
	/bin/false
non-default-param-after-default2 param0='value'  *  $  PARAM:
	env
non-default-param-after-default3 param0='value' param1 param2 param3 param4=something param5:
	/bin/false
non-default-param-after-default4 param0='''
value
''' param1  + $ param2:
	env

[confirm()]
argless-attribute1:
	/bin/false

[confirm(  )]
argless-attribute2:
	/bin/false

[confirm  \
  (
   
  \
) ]
argless-attribute3:
	/bin/false

invalid_multi_line_interp:
	echo {{"foo" + \
bar }}
	echo this line is not part of the recipe body

[group: group]
invalid-shorthand-attr-value:

[group: x]
invalid-shorthand-attr-value2:

[group::-]
invalid-shorthand-attr-value3:

[group: , unix]
comma-is-not-invalid-attr-value:

[script: 'bash', "-x", '-c']
attr-shorthand-takes-only-one-argument:


recipe-without-body:
# comment
	echo this line is not recipe body
