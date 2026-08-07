set unstable
set lists

foo := 'foo' && '' || 'foo'
fdfind := which('fd') || require('fdfind')

canonical_false := bool("false")
jobs := num_jobs()
split_list := split("a\u{0}b\u{0}c", "\u{0}")
joined := join_list(["a", "b", "c"], '\x00')

negated := !"true"
negated2 := ! "true"
negated3 := !\
"true"

elseless_if := if "a" == "b" { "this branch is unreachable" }
assert_by_value := assert("foo")
conditional_value := "a" =~ '^[a-z]'

zero := len([])

list_of_lists := ["a", ["b", "c"] ++ ["d"], "e"] ++ ["f", "g", "h"]


[
arg('flag', short, long, flag),
arg('FILES', min='2', max='4')
]
backup_minmax flag +FILES:
	echo {{FILES}}

[parallel]
build target *platform: *(compile target *platform)

@compile target platform:
  echo compiling {{ target }} for {{ platform }}…
