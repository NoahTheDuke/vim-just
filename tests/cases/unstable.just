set unstable
set lists

foo := 'foo' && '' || 'foo'
fdfind := which('fd') || require('fdfind')

canonical_false := bool("false")
jobs := num_jobs()
split_list := split("a\u{0}b\u{0}c", "\u{0}")

negated := !"true"
negated2 := ! "true"
negated3 := !\
"true"
