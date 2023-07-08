 !include not-at-beginning-of-line.just

set shell
set shell := []
set shell := [  ]
set shell := [
	
]

bash := 'bash'
c := '-c'
set shell := [bash, c]

# export is only valid when prefixing an assignment
# just thinks the following line is a malformed attempt to start a recipe called "export"
export FOO

	(the next line is not a recipe body)...
	this text should not be highlighted

badfunc1 := arch(foo) + os(foo) + os_family(foo)

badfunc2 := invocation_directory(bar) / invocation_directory_native(bar)
badfunc3 := justfile_directory(bar) / justfile(bar, foo)

badfunc4 := justfile   (
  abc def
)

not_a_recipe_name #comment:
	not a recipe body

nonexistant_func := blahuuid()
nonexistant_func2 := blah_replace_regex('foo', '([^o])', '$1')

not_a_recipe_start
	not a recipe body
badfunc_in_interpolation:
	{{just_executable(this)}} {{quote( uuid(random, foo) )}}

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

variadic-env-wrong-order1 param0=foo $*PARAM:
	env
variadic-env-wrong-order2 $+PARAM="1":
	env
variadic-env-wrong-order-with-whitespace $  *  PARAM:
	env
