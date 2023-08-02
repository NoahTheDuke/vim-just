set \
ignore-comments := true

set \
  fallback \
     := \
        false


var \
      :=\
'1' + '2' \
\
      + '3' /\
'456' + \
if \
'a' \
!= \
'b' \
{\
  '\789'} \
else\
{ '\543'\
\
}


f1 := \
uuid\
\
\
(\

    )

f2 := env (\

  'FOO_VAR', \

'0'\

)

f3 := replace_regex \
( \
  "FOOoo",
  "([A-Z])[A-Z]+([^A-Z])", \
  "$1${2}"
\
)

test: a \
	b
	echo '123'

a:
	echo 'A'
b:
	echo 'B'
c:
	echo 'C'
	# ignored line

test2 \
    param1="foo" param2 \
  =  '''
bar'''\
param3 = \
      "b\
a\
z" \
\
 * \
  $ \
  param4 \
= \
f1 :
	echo {{param1}} {{param2}} {{param3}} {{param4}}

test3: \
	a b \
	c #comment \
  echo d
  echo 'Test 3'

test4 \
	+$PARAM='1': test \
	( \
	  test2 \
	  'bar'
	
	)
	env | grep -F PARAM

test5: a \
	\
	\
	\
	b
	echo 'Test5'

test6: a\
b
	echo 'Test6'

# the trailing space after the closing ] is intentional
[\
 no-cd \
  \
, unix \
   ] 
test7:
	pwd

alias\
runpwd\
:=\
test7

test8 param1 \
= \
( f1 + 'X' + f2) \
:
	echo {{ \
	  param1 \
	}}

test9:
  echo {{\
    uuid() \
  }}
