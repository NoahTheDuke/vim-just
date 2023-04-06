 !include not-at-beginning-of-line.just

badfunc1 := arch(foo) + os(foo) + os_family(foo)

badfunc2 := invocation_directory(bar) / invocation_directory_native(bar)
badfunc3 := justfile_directory(bar) / justfile(bar, foo)

badfunc4 := justfile   (
  abc def
)

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
