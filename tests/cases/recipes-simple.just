# This file intentionally does not have newline at end of file

empty:

tab:
	echo
space-indent:
  echo foo foo-bar bar

alias foo := tab

alias:
  echo alias

simple_dep: dependency5

simple_multiline:
	echo 123
	cat comment.just

simple_multidep: dependency dependency2 dependency3
	/bin/true


dependency:
  echo Dependency1
dependency2:


dependency3:
dependency4:
dependency5:
	echo Dependency5 line1
	echo Dependency5 line2