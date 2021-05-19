" Vim syntax file
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" Last Change:	2021 May 18

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "just"

" BACKTICK            = `[^`]*`
syntax region justBacktick start=/\v`/ skip=/\v\\./ end=/\v`/
" COMMENT             = #([^!].*)?$
syntax match justComment "\v#[^!].*$"
" NAME                = [a-zA-Z_][a-zA-Z0-9_-]*
syntax match justName "\v\s\zs[a-zA-Z_][a-zA-Z0-9_-]*" contained
" RAW_STRING          = '[^']*'
syntax region justRawString start=/\v'/ skip=/\v\\./ end=/\v'/
" STRING              = "[^"]*" # also processes \n \r \t \" \\ escapes
syntax region justString start=/\v"/ skip=/\v\\./ end=/\v"/ contains=@justSpecialStrings

syntax cluster justAllStrings contains=justBacktick,justRawString,justString
" interpolation : '{{' expression '}}'
syntax region justInterpolation start="{{" end="}}" contained contains=ALLBUT,@justStringNotTop

syntax cluster justSpecialStrings contains=justInterpolation
syntax cluster justStringNotTop contains=@justSpecialStrings

syntax match justAssignmentOperator "\v\:\=" contained skipwhite nextgroup=justBoolean,justName,justSettingShell

" recipe        : '@'? NAME parameter* variadic? ':' dependency* body?
syntax match justRecipe "\v^\@?[a-zA-Z_][a-zA-Z0-9_-]*" contained
syntax match justRecipeColon "\v^\@?.{-}:" contains=ALL
" parameter     : NAME
"               | NAME '=' value
syntax match justParameter "\v\s[a-zA-Z_][a-zA-Z0-9_-]*\=?" contained contains=justParameterOperator nextgroup=justName
syntax match justParameterOperator "=" contained
" variadic      : '*' parameter
"               | '+' parameter
syntax match justVariadic "\v%(\*|\+)[a-zA-Z_][a-zA-Z0-9_-]*\=?" contained contains=justVariadicOperator nextgroup=justName,justRecipeColon
syntax match justVariadicOperator "\v\*|\+" contained

" assignment    : NAME ':=' expression eol

" boolean       : ':=' ('true' | 'false')
syntax match justBoolean "\v(true|false)" contained

" setting       : 'set' 'dotenv-load' boolean?
"               | 'set' 'export' boolean?
"               | 'set' 'positional-arguments' boolean?
"               | 'set' 'shell' ':=' '[' string (',' string)* ','? ']'
syntax match justSet "^set" skipwhite nextgroup=justSetting
syntax match justSetting "\v%(dotenv-load|export|positional-arguments)" contains=justSet skipwhite nextgroup=justAssignmentOperator
syntax region justSettingShell start="\[" end="\]" contains=@justAllStrings
syntax region justSetting start=/\vshell/ end=/\v%(\:\=)@=/ contains=justAssignmentOperator skipwhite nextgroup=justAssignmentOperator

" alias : 'alias' NAME ':=' NAME
syntax match justAliasKeyword "\v^alias" skipwhite nextgroup=justAlias
syntax region justAlias start=/\v^alias\s+[a-zA-Z_][a-zA-Z0-9_-]*/ end=/\v%(\:\=)@=/ contains=justName,justAssignmentOperator skipwhite nextgroup=justAssignmentOperator

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

" dependency    : NAME
"               | '(' NAME expression* ')'
" syntax match justDependency "\v\s\zs[a-zA-Z_][a-zA-Z0-9_-]*" contained
" syntax region justDependency start="(" end=")" skipwhite contains=ALL

" line          : LINE (TEXT | interpolation)+ NEWLINE
syntax match justLine "\v^\s+.*$" contains=justInterpolation

highlight link justAlias Keyword
highlight link justAliasKeyword Keyword
highlight link justAssignmentOperator Operator
highlight link justBacktick String
highlight link justBoolean Boolean
highlight link justBraces Delimiter
highlight link justComment Comment
highlight link justConditional Conditional
highlight link justInterpolation Delimiter
highlight link justLine Struct
highlight link justName Identifier
highlight link justOperator Operator
highlight link justRawString String
highlight link justRecipe Function
highlight link justRecipeColon Operator
highlight link justSet Keyword
highlight link justSetting Type
highlight link justString String
highlight link justVariadic Error
