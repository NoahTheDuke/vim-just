foo := replace_regex(justfile(), '[^A-Za-z]([A-Za-z]+)\.just$', ' - Test $1')

foo2 := replace_regex("""
   \tLorem ipsum dolor sit amet, consectetur adipiscing elit, sed
   do eiusmod tempor incididunt ut labore et dolore
   disputandum putant. Sed ut omittam pericula, labores,
   dolorem etiam, quem optimus quisque pro patria et pro suis
   suscipit, ut non plus habeat sapiens, quod gaudeat, quam
   quod angatur. Optime vero Epicurus, quod exiguam dixit
   fortunam intervenire sapienti maximasque ab eo dissentiunt,
   sed certe non.
""", '\W(?P<Abc1_>\w{2})\W', " _$Abc1_-")

foo3 := replace_regex(`echo ${HOME}`, '/(\w+)/(\w+)', '${2}at${1}')

foo4 := replace_regex('$T$es$t',
  '\$([tT])'
  ,
  '$1'
 )

foo5 := replace_regex("any\n$123", '\$123', """
\t$$abc$
234\
345 ${456}567
""")

foo6 := replace_regex("Some text.", '([^a-z])', '$$$1$$2')

foo7 := replace_regex("Some text.", '([^a-z])', '$$1')

foo8 := replace_regex("test123", '\w(\d+)', '''
  \t'$1''')

foo9 := replace_regex("trailing comma is accepted after the final argument,",
  "(\\W+)", \
  "${1}_$1",
)

foo10 := replace_regex("_abcdef",
  '(\w)[a-z]+', \

  '${1}'
  , \
)

foo11 := replace_regex(HEX, '\d+', "$$$$1")

not_a_replacement := 'test $1 test '
not_a_replacement_2 := "test $Abc_ test"

not_a_regex := replace('Foo Bar', ' ', '$1')

# special highlighting should only occur in the simplest case
replacement_conditional := replace_regex('123456789', '([2468])', if "$1" == "$2" { '$1_' } else { '_${1}_' })
replacement_nested_func := replace_regex('987654321', '([13579])', trim_start(' $1 '))
replacement_split := replace_regex('012034', '(?P<capture>[1-9]+)', "!$cap" + 'ture' + '$captu' / "re")

replacement_in_interp:
	echo '{{replace_regex('A b c d', '\s(\w)', '1$1')}}'
	echo {{replace_regex(replacement_conditional, '(\d+)', foo3)}}
