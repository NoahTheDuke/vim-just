" Vim syntax file
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just.git
" Last Change:	2021 May 19

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'just'
syn sync minlines=20 maxlines=200

syn match justNoise ","

syn match justComment "\v#.*$" contains=@Spell
syn match justName "[a-zA-Z_][a-zA-Z0-9_-]*" contained
syn match justFunction "[a-zA-Z_][a-zA-Z0-9_-]*" contained

syn region justBacktick start=/`/ skip=/\./ end=/`/ contains=justInterpolation
syn region justRawString start=/'/ skip=/\./ end=/'/ contains=justInterpolation
syn region justString start=/"/ skip=/\./ end=/"/ contains=justInterpolation
syn cluster justAllStrings contains=justBacktick,justRawString,justString

syn match justAssignmentOperator ":=" contained

syn match justParameterOperator "=" contained
syn match justVariadicOperator "*\|+\|\$" contained
syn match justParameter "\v\s\zs%(\*|\+|\$)?[a-zA-Z_][a-zA-Z0-9_-]*\ze\=?" contained contains=justVariadicOperator,justParameterOperator

syn match justNextLine "\\\n\s*"
syn match justRecipeAt "^@" contained
syn match justRecipeColon "\v:" contained

syn region justRecipe
      \ matchgroup=justRecipeBody start="\v^\@?[a-zA-Z_]((:\=)@!.)*\ze:%(\s|\n)"
      \ matchgroup=justRecipeDeps end="\v:\zs.*\n"
      \ contains=justFunction,justRecipeColon

syn match justRecipeBody "\v^\@?[a-zA-Z_]((:\=)@!.)*\ze:%(\s|\n)"
      \ contains=justRecipeAt,justRecipeColon,justParameter,justParameterOperator,justVariadicOperator,@justAllStrings,justComment

syn match justRecipeDeps "\v:[^\=]?.*\n"
      \ contains=justComment,justFunction,justRecipeColon

syn match justBoolean "\v(true|false)" contained
syn match justKeywords "\v%(export|set)" contained

syn match justAssignment "\v^[a-zA-Z_][a-zA-Z0-9_-]*\s+:\=" transparent contains=justAssignmentOperator

syn match justSetKeywords "\v%(dotenv-load|export|positional-arguments|shell)" contained
syn match justSetDefinition "\v^set\s+%(dotenv-load|export|positional-arguments)%(\s+:\=\s+%(true|false))?$"
      \ contains=justSetKeywords,justKeywords,justAssignmentOperator,justBoolean
      \ transparent

syn match justSetBraces "\v[\[\]]" contained
syn region justSetDefinition
      \ start="\v^set\s+shell\s+:\=\s+\["
      \ end="]"
      \ contains=justSetKeywords,justKeywords,justAssignmentOperator,@justAllStrings,justNoise,justSetBraces
      \ transparent skipwhite oneline

syn region justAlias
      \ matchgroup=justAlias start="\v^alias\ze\s+[a-zA-Z_][a-zA-Z0-9_-]*\s+:\="
      \ end="$"
      \ contains=justKeywords,justFunction,justAssignmentOperator
      \ oneline skipwhite

syn region justExport
      \ matchgroup=justExport start="\v^export\ze\s+[a-zA-Z_][a-zA-Z0-9_-]*%(\s+:\=)?"
      \ end="$"
      \ contains=justKeywords,justAssignmentOperator
      \ transparent oneline skipwhite

syn keyword justConditional if else
syn region justConditionalBraces start="\v[^{]\{[^{]" end="}" contained oneline contains=ALLBUT,justConditionalBraces,justBodyText

syn match justBodyText "[^[:space:]#]\+" contained
syn match justLineLeadingSymbol "\v^\s+\zs%(\@|-)" contained
syn match justLineContinuation "\\$" contained

syn region justBody transparent matchgroup=justLineLeadingSymbol start="\v^\s+\zs[@-]"hs=e-1 matchgroup=justBodyText start="\v^\s+\zs[^[:space:]@#-]"hs=e-1 end="\n" skipwhite oneline contains=justInterpolation,justBodyText,justLineLeadingSymbol,justLineContinuation,justComment

syn region justInterpolation start="{{" end="}}" contained contains=ALLBUT,justInterpolation,justFunction,justBodyText

syn match justBuiltInFunctionParens "[()]" contained
syn match justBuiltInFunctions "\v%(arch|os|os_family|invocation_directory|justfile|justfile_directory|just_executable)\ze\(\)" contains=justBuiltInFunctions
syn region justBuiltInFunctions transparent matchgroup=justBuiltInFunctions start="\v%(env_var_or_default|env_var)\ze\(" end=")" oneline contains=@justAllStrings,justBuiltInFunctionParens,justNoise

syn match justBuiltInFunctionsError "\v%(arch|os|os_family|invocation_directory|justfile|justfile_directory|just_executable)\(.+\)"

syn match justOperator "\v%(\=\=|!\=|\+)"

hi def link justAlias                 Keyword
hi def link justAssignmentOperator    Operator
hi def link justBacktick              String
hi def link justBodyText              Constant
hi def link justBoolean               Boolean
hi def link justBuiltInFunctions      Function
hi def link justBuiltInFunctionsError Error
hi def link justBuiltInFunctionParens Delimiter
hi def link justComment               Comment
hi def link justConditional           Conditional
hi def link justConditionalBraces     Delimiter
hi def link justExport                Keyword
hi def link justFunction              Function
hi def link justInterpolation         Delimiter
hi def link justKeywords              Keyword
hi def link justLineContinuation      Special
hi def link justLineLeadingSymbol     Special
hi def link justName                  Identifier
hi def link justNextLine              Special
hi def link justOperator              Operator
hi def link justParameter             Identifier
hi def link justParameterOperator     Operator
hi def link justRawString             String
hi def link justRecipe                Function
hi def link justRecipeAt              Special
hi def link justRecipeBody            Function
hi def link justRecipeColon           Operator
hi def link justSetDefinition         Keyword
hi def link justSetKeywords           Keyword
hi def link justString                String
hi def link justVariadicOperator      Operator
