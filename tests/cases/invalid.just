 !include not-at-beginning-of-line.just

badfunc1 := arch(foo) + os(foo) + os_family(foo)

badfunc2 := invocation_directory(bar) / invocation_directory_native(bar)
badfunc3 := justfile_directory(bar) / justfile(bar, foo)

badfunc_in_interpolation:
	{{just_executable(this)}} {{quote( uuid(random, foo) )}}

invalid_recipe_body:
 	  echo 'My indentation mixes tabs and spaces!'

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
