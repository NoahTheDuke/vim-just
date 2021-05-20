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

" COMMENT             = #([^!].*)?$
syntax match justComment "\v#.*$" contains=@Spell

" NAME                = [a-zA-Z_][a-zA-Z0-9_-]*
syntax match justName "\v[a-zA-Z_][a-zA-Z0-9_-]*" contained

" BACKTICK            = `[^`]*`
syntax region justBacktick start=/`/ skip=/\./ end=/`/ contains=justInterpolation
" RAW_STRING          = '[^']*'
syntax region justRawString start=/'/ skip=/\./ end=/'/ contains=justInterpolation
" STRING              = "[^"]*" # also processes \n \r \t \" \\ escapes
syntax region justString start=/"/ skip=/\./ end=/"/ contains=justInterpolation

syntax cluster justAllStrings contains=justBacktick,justRawString,justString
" interpolation : '{{' expression '}}'
syntax region justInterpolation start="{{" end="}}" contained contains=ALLBUT,@justStringNotTop

syntax cluster justStringNotTop contains=justInterpolation

syntax match justAssignmentOperator ":=" contained skipwhite nextgroup=justBoolean

" dependency    : NAME
"               | '(' NAME expression* ')'
" syntax match justDependency "\v:(\=)@!\s+\zs[a-zA-Z_][a-zA-Z0-9_-]*" contained
" syntax region justDependency start="\v:(\=)@!.*\zs\(" end=")" skipwhite contained contains=justRecipeColon,justName

" recipe        : '@'? NAME parameter* variadic? ':' dependency* body?
syntax match justRecipeAt "\v^\@\ze[a-zA-Z_]" contained
syntax match justRecipeColon "\v:(\=)@!" contained
syntax match justRecipe "\v^\@?[a-zA-Z_].*:(\=)@!" contains=justRecipeAt,justRecipeColon,justParameter,justParameterOperator,justVariadic,justVariadicOperator,@justAllStrings

" parameter     : NAME
"               | NAME '=' value
syntax match justParameterOperator "=" contained
syntax match justParameter "\v\s\zs[a-zA-Z_][a-zA-Z0-9_-]*\ze\=?" contained contains=justParameterOperator

" variadic      : '*' parameter
"               | '+' parameter
syntax match justVariadicOperator "\v\*|\+" contained
syntax match justVariadic "\v%(\*|\+)[a-zA-Z_][a-zA-Z0-9_-]*\ze\=?" contained contains=justVariadicOperator,justParameter nextgroup=justName,justRecipeColon

" assignment    : NAME ':=' expression eol
syntax match justAssignment "\v^[a-zA-Z_][a-zA-Z0-9_-]*\s+:\=" skipwhite contains=justName,justAssignmentOperator

" export        : 'export' assignment
syntax match justExportKeyword "\v^export" contained skipwhite nextgroup=justExport
syntax region justExport start=/\v^export\s+[a-zA-Z_][a-zA-Z0-9_-]*/ end=/\v%(\:\=)@=/ contains=justExportKeyword,justName,justAssignmentOperator skipwhite nextgroup=justAssignmentOperator

" boolean       : ':=' ('true' | 'false')
syntax match justBoolean "\v(true|false)" contained

" setting       : 'set' 'dotenv-load' boolean?
"               | 'set' 'export' boolean?
"               | 'set' 'positional-arguments' boolean?
"               | 'set' 'shell' ':=' '[' string (',' string)* ','? ']'
syntax match justSetKeyword "^set" contained skipwhite nextgroup=justSetDefinition
syntax match justSetDefinition "\v^set\s+%(dotenv-load|export|positional-arguments)%(\s+:\=\s+%(true|false))?$" contains=justSetKeyword,justAssignmentOperator,justBoolean
syntax match justSetBraces "\v[\[\]]" contained
syntax region justSetDefinition start="\v^set\s+shell\s+:\=\s+\[" end="]" skipwhite oneline contains=justSetKeyword,justAssignmentOperator,@justAllStrings,justNoise,justSetBraces

" alias : 'alias' NAME ':=' NAME
syntax match justAliasKeyword "\v^alias" contained skipwhite nextgroup=justAlias
syntax region justAlias start=/\v^alias\s+[a-zA-Z_][a-zA-Z0-9_-]*/ end=/\v%(\:\=)@=/ contains=justAliasKeyword,justName,justAssignmentOperator skipwhite nextgroup=justAssignmentOperator

" expression    : 'if' condition '{' expression '}' 'else' '{' expression '}'
"               | value '+' expression
"               | value
syntax keyword justConditional if else
syntax region justConditionalBraces start="\v[^{]\{[^{]" end="}" contained contains=ALLBUT,justConditionalBraces

" condition     : expression '==' expression
"               | expression '!=' expression

" value         : NAME '(' sequence? ')'
"               | BACKTICK
"               | INDENTED_BACKTICK
"               | NAME
"               | string
"               | '(' expression ')'

" sequence      : expression ',' sequence
"               | expression ','?

" line          : LINE (TEXT | interpolation)+ NEWLINE
" body          : INDENT line+ DEDENT
syntax match justLineAt "\v^\s+\@" contained
syntax match justLineContinuation "\\\n."he=e-1 contained
syntax region justBody start="\v^\s+" end="\v^[^\s#]"me=e-1,re=e-1 end="^$" contains=justLineAt,justLineContinuation,justInterpolation,justComment

syntax match justBuiltInFunctionParens "[()]" contained
syntax match justBuiltInFunctions "\v%(arch|os|os_family|invocation_directory|justfile|justfile_directory|just_executable)\ze\(\)"
syntax match justBuiltInFunctions "\venv_var\ze\(\".{-}\"\)" contains=@justAllStrings,justBuiltInFunctionParens
syntax match justBuiltInFunctions "\venv_var_or_default\ze\(\".{-}\", \".{-}\"\)" contains=justNoise,@justAllStrings,justBuiltInFunctionParens

syntax match justNumber "\v[0-9]+"
syntax match justOperator "\v%(\=\=|!\=|\+)"

highlight default link justAlias                 Keyword
highlight default link justAliasKeyword          Keyword
highlight default link justAssignmentOperator    Operator
highlight default link justBacktick              String
highlight default link justBody                  Constant
highlight default link justBoolean               Boolean
highlight default link justBuiltInFunctions      Function
highlight default link justBuiltInFunctionParens Delimiter
highlight default link justComment               Comment
highlight default link justConditional           Conditional
highlight default link justConditionalBraces     Delimiter
highlight default link justExport                Identifier
highlight default link justExportKeyword         Keyword
highlight default link justInterpolation         Delimiter
highlight default link justLineAt                Operator
highlight default link justLineContinuation      Special
highlight default link justName                  Identifier
highlight default link justNumber                Number
highlight default link justOperator              Operator
highlight default link justParameter             Identifier
highlight default link justParameterOperator     Operator
highlight default link justRawString             String
highlight default link justRecipe                Function
highlight default link justRecipeAt              Operator
highlight default link justRecipeColon           Operator
highlight default link justSetDefinition         Keyword
highlight default link justSetKeyword            Keyword
highlight default link justString                String
highlight default link justVariadic              Identifier
highlight default link justVariadicOperator      Operator
