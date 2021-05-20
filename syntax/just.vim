" Vim syntax file
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just.git
" Last Change:	2021 May 19

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'just'
syntax sync minlines=20 maxlines=200

syntax match justNoise ","

syntax match justComment "\v#.*$" contains=@Spell
syntax match justName "\v[a-zA-Z_][a-zA-Z0-9_-]*" contained
syntax match justFunction "\v[a-zA-Z_][a-zA-Z0-9_-]*" contained

syntax region justBacktick start=/`/ skip=/\./ end=/`/ contains=justInterpolation
syntax region justRawString start=/'/ skip=/\./ end=/'/ contains=justInterpolation
syntax region justString start=/"/ skip=/\./ end=/"/ contains=justInterpolation
syntax cluster justAllStrings contains=justRawString,justString
syntax region justInterpolation start="{{" end="}}" contained

syntax match justAssignmentOperator ":="

syntax match justParameterOperator "=" contained
syntax match justVariadicOperator "*\|+" contained
syntax match justParameter "\v\s\zs%(\*|\+)?[a-zA-Z_][a-zA-Z0-9_-]*\ze\=?" contained contains=justName,justVariadicOperator,justParameterOperator

syntax region justDependency start="(" end=")" skipwhite contained contains=ALLBUT,justDependency,justRecipe,justBody,justBuiltInFunctionParens

syntax match justRecipeAt "^@" contained
syntax match justRecipeColon "\v:(\=)@!" contained
syntax region justRecipe transparent matchgroup=justRecipe start="\v^\@?[a-zA-Z_][a-zA-Z0-9"'`=+_[:blank:]-]*\ze:%(\s|$)" end="$" contains=justFunction,justDependency,justRecipeAt,justRecipeColon,justParameter,justParameterOperator,justVariadicOperator,@justAllStrings,justDependency,justComment skipnl nextgroup=justBody
syntax match justRecipe "\v^\@?[a-zA-Z_][a-zA-Z0-9"'`=+_[:blank:]-]*:%(\s+.*)*$" contains=justFunction,justDependency,justRecipeAt,justRecipeColon,justParameter,justParameterOperator,justVariadicOperator,@justAllStrings,justDependency,justComment skipnl nextgroup=justBody

syntax match justBoolean "\v(true|false)" contained
syntax match justKeywords "\v%(export|set)"

syntax match justSetKeywords "\v%(dotenv-load|export|positional-arguments|shell)" contained
syntax match justSetDefinition transparent "\v^set\s+%(dotenv-load|export|positional-arguments)%(\s+:\=\s+%(true|false))?$" contains=justSetKeywords,justKeywords,justAssignmentOperator,justBoolean
syntax match justSetBraces "\v[\[\]]" contained
syntax region justSetDefinition transparent start="\v^set\s+shell\s+:\=\s+\[" end="]" skipwhite oneline contains=justSetKeywords,justKeywords,justAssignmentOperator,@justAllStrings,justNoise,justSetBraces

syntax region justAlias matchgroup=justAlias start="\v^alias" end="$" oneline skipwhite contains=justKeywords,justFunction,justAssignmentOperator

syntax keyword justConditional if else
syntax region justConditionalBraces start="\v[^{]\{[^{]" end="}" contained contains=ALLBUT,justConditionalBraces

syntax match justLineAt "\v^\s+\zs\@" contained
syntax match justLineContinuation "\\\n."he=e-1 contained
syntax region justBody start="\v^\s+" end="\v^[^\s#]"me=e-1,re=e-1 end="^$" contained contains=justLineAt,justLineContinuation,justInterpolation,justComment

syntax sync match justBodySync groupthere NONE "^[^[:blank]#]"
syntax sync match justBodySync groupthere justBody "\v^\@?[a-zA-Z_].*:(\=)@!.*$"

syntax match justBuiltInFunctionParens "[()]" contained
syntax match justBuiltInFunctions "\v%(arch|os|os_family|invocation_directory|justfile|justfile_directory|just_executable)\ze\(\)" contains=justBuiltInFunctions
syntax region justBuiltInFunctions transparent matchgroup=justBuiltInFunctions start="\v%(env_var_or_default|env_var)\ze\(" end=")" oneline contains=@justAllStrings,justBuiltInFunctionParens,justNoise

syntax match justBuiltInFunctionsError "\v%(arch|os|os_family|invocation_directory|justfile|justfile_directory|just_executable)\(.+\)"

syntax match justNumber "\v[0-9]+"
syntax match justOperator "\v%(\=\=|!\=|\+)"

highlight default link justAlias                 Keyword
highlight default link justAssignmentOperator    Operator
highlight default link justBacktick              String
highlight default link justBody                  Constant
highlight default link justBoolean               Boolean
highlight default link justBuiltInFunctions      Function
highlight default link justBuiltInFunctionsError Error
highlight default link justBuiltInFunctionParens Delimiter
highlight default link justComment               Comment
highlight default link justConditional           Conditional
highlight default link justConditionalBraces     Delimiter
highlight default link justDependency            Delimiter
highlight default link justExport                Identifier
highlight default link justFunction              Function
highlight default link justInterpolation         Delimiter
highlight default link justKeywords              Keyword
highlight default link justLineAt                Operator
highlight default link justLineContinuation      Special
highlight default link justName                  Identifier
highlight default link justNumber                Number
highlight default link justOperator              Operator
highlight default link justParameter             Identifier
highlight default link justParameterOperator     Operator
highlight default link justRawString             String
highlight default link justRecipeAt              Operator
highlight default link justRecipeColon           Operator
highlight default link justSetDefinition         Keyword
highlight default link justSetKeywords           Keyword
highlight default link justString                String
highlight default link justVariadicOperator      Operator
