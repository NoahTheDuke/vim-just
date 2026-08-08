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

# === User-defined functions ===
hello(name) := f"Hello, {{ name }}!"
greet (name) := "Hi, " + name + "!"

wave\
(greeting) := greeting + "..."

hyphenate(a, b) := a + "-" + b

tabbed(	a	,	b	) := a + " " + b

multiline_params(
  x,
  y
) := x + "
" + y

extra_close(name ) := name + "?"

nospace_assign(name):= name + "!?"

no_space_at_all(name):=f'|{{name}}|'

many_spaces(name)   :=  name + foo

backslash_assign(greeting)\
:= greeting + "!"

double(x) := x + "* 2"
triple(x) := replace_regex(double(x), '2$', '3')
quadruple(x) := double(double(x))

truthy(val) := if val == "1" { "yes" } else { "no" }

fancy( name ) := f"""\n  {{name}}\n  """

shadowuuid() := uuid()
shadow_replace_regex(str, pat, repl) := replace_regex(str, pat, repl)
user_func_prefixing_builtin_func_name := shadow_replace_regex(shadowuuid(), '-', '')


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
