" Vim syntax file
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just/blob/master/syntax/just.vim
" Last Change:	2021 May 19

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'just'
syntax sync fromstart

syntax match justNoise ","

" COMMENT             = #([^!].*)?$
syntax match justComment "\v#[^!].*$"

" NAME                = [a-zA-Z_][a-zA-Z0-9_-]*
syntax match justName "\v[a-zA-Z_][a-zA-Z0-9_-]*" contained

" BACKTICK            = `[^`]*`
syntax region justBacktick start=/\v`/ skip=/\v\\./ end=/\v`/ contains=justInterpolation
" RAW_STRING          = '[^']*'
syntax region justRawString start=/\v'/ skip=/\v\\./ end=/\v'/ contains=justInterpolation
" STRING              = "[^"]*" # also processes \n \r \t \" \\ escapes
syntax region justString start=/\v"/ skip=/\v\\./ end=/\v"/ contains=justInterpolation

syntax cluster justAllStrings contains=justBacktick,justRawString,justString
" interpolation : '{{' expression '}}'
syntax region justInterpolation start="{{" end="}}" contained contains=ALLBUT,@justStringNotTop

syntax cluster justStringNotTop contains=justInterpolation

syntax match justAssignmentOperator "\v:\=" contained skipwhite nextgroup=justBoolean,justSettingShell

" dependency    : NAME
"               | '(' NAME expression* ')'
" syntax match justDependency "\v:(\=)@!\s+\zs[a-zA-Z_][a-zA-Z0-9_-]*" contained
" syntax region justDependency start="\v:(\=)@!.*\zs\(" end=")" skipwhite contained contains=justRecipeColon,justName

" recipe        : '@'? NAME parameter* variadic? ':' dependency* body?
syntax match justRecipeAt "\v^\@\ze[a-zA-Z_]" contained
syntax match justRecipeColon "\v:(\=)@!" contained
syntax match justRecipe "\v^\@?.{-}:(\=)@!" contains=ALLBUT,justName,justRecipe
" parameter     : NAME
"               | NAME '=' value
syntax match justParameterOperator "\v\=" contained
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
syntax match justSet "^set" contained skipwhite nextgroup=justSetting
syntax region justSetting start="^set" end="\v%(dotenv-load|export|positional-arguments|shell)" oneline skipwhite contains=justSet,justSetting
syntax region justSettingShell start="\[" end="\]" oneline contains=@justAllStrings
syntax match justSetting "\vshell\s+%(\:\=)@=" skipwhite contains=justAssignmentOperator nextgroup=justAssignmentOperator

" alias : 'alias' NAME ':=' NAME
syntax match justAliasKeyword "\v^alias" contained skipwhite nextgroup=justAlias
syntax region justAlias start=/\v^alias\s+[a-zA-Z_][a-zA-Z0-9_-]*/ end=/\v%(\:\=)@=/ contains=justAliasKeyword,justName,justAssignmentOperator skipwhite nextgroup=justAssignmentOperator

" expression    : 'if' condition '{' expression '}' 'else' '{' expression '}'
"               | value '+' expression
"               | value
syntax keyword justConditional if else
syntax region justBraces start="\v[^{]\{[^{]" end="}" contained contains=ALL

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
syntax match justLineAt "\v^\s+\@" contained
syntax match justLine "\v^\s+.*$" contains=justLineAt,justInterpolation,@justAllStrings

syntax match justBuiltInFunctions "\v%(arch|os|os_family|invocation_directory|justfile|justfile_directory|just_executable)\ze\(\)" contained
syntax match justBuiltInFunctionsEnv "\v%(env_key_or_default|env_key)\ze\(.+\)" contained
syntax match justBuiltInFunctionParens "[()]" contained
syntax region justBuiltInFunctions start=/\v%(env_key_or_default|env_key)\(@=/ end=/)\@=/ oneline contains=justNoise,justBuiltInFunctionParens,justBuiltInFunctionsEnv,justName

highlight link justAlias Keyword
highlight link justAliasKeyword Keyword
highlight link justAssignmentOperator Operator
highlight link justBacktick String
highlight link justBoolean Boolean
highlight link justBraces Delimiter
highlight link justBuiltInFunctions Function
highlight link justBuiltInFunctionsEnv Function
highlight link justComment Comment
highlight link justConditional Conditional
highlight link justExport Identifier
highlight link justExportKeyword Keyword
highlight link justInterpolation Delimiter
highlight link justLineAt Operator
highlight link justName Identifier
highlight link justOperator Operator
highlight link justParameter Identifier
highlight link justParameterOperator Operator
highlight link justRawString String
highlight link justRecipe Function
highlight link justRecipeAt Operator
highlight link justRecipeColon Operator
highlight link justSet Keyword
highlight link justSetting Type
highlight link justString String
highlight link justVariadic Identifier
highlight link justVariadicOperator Operator
