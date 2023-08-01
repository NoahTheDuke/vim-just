" Vim syntax file
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just.git
" Last Change:	2023 Apr 12

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'just'
syn sync fromstart

syn match justNoise ","

syn match justComment "\v#%([^!].*)?$" contains=@Spell,justCommentTodo
syn keyword justCommentTodo TODO FIXME XXX contained
syn match justShebang "#!.*$" contains=justInterpolation
syn match justName "[a-zA-Z_][a-zA-Z0-9_-]*" contained
syn match justFunction "[a-zA-Z_][a-zA-Z0-9_-]*" contained

syn match justPreBodyComment "\v\s*#%([^!].*)?\n%(\t+| +)@=" transparent contained contains=justComment
      \ nextgroup=@justBodies skipnl

syn region justBacktick start=/`/ end=/`/
syn region justBacktick start=/```/ end=/```/
syn region justRawString start=/'/ end=/'/
syn region justRawString start=/'''/ end=/'''/
syn region justString start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=justLineContinuation,justStringEscapeSequence
syn region justString start=/"""/ skip=/\\\\\|\\"/ end=/"""/ contains=justLineContinuation,justStringEscapeSequence
syn cluster justAllStrings contains=justBacktick,justRawString,justString

syn match justRegexReplacement /\v,\_s*%('%([^']|\n)*'|'''%(\_.%(''')@!)*\_.?''')\_s*\)/me=e-1 transparent contained contains=@justExpr,@justStringsWithRegexCapture
syn match justRegexReplacement /\v,\_s*%("%([^"]|\\"|\n)*"|"""%(\_.%(""")@!)*\_.?""")\_s*\)/me=e-1 transparent contained contains=@justExpr,@justStringsWithRegexCapture
syn region justRawStrRegexRepl start=/\v'/ end=/'/ contained contains=justRegexCapture
syn region justRawStrRegexRepl start=/\v'''/ end=/'''/ contained contains=justRegexCapture
syn region justStringRegexRepl start=/\v"/ skip=/\\\\\|\\"/ end=/"/ contained contains=justLineContinuation,justStringEscapeSequence,justRegexCapture
syn region justStringRegexRepl start=/\v"""/ skip=/\\\\\|\\"/ end=/"""/ contained contains=justLineContinuation,justStringEscapeSequence,justRegexCapture
syn match justRegexCapture '\v%(\$@1<!\$)@3<!\$%([0-9A-Za-z_]+|\{[0-9A-Za-z_]+\})' contained
syn cluster justStringsWithRegexCapture contains=justRawStrRegexRepl,justStringRegexRepl

syn region justStringInsideBody start=/\v\\@1<!'/ end=/'/ contained contains=justLineContinuation,justInterpolation,@justOtherCurlyBraces,justIndentError
syn region justStringInsideBody start=/\v\\@1<!"/ skip=/\v\\@1<!\\"/ end=/"/ contained contains=justLineContinuation,justInterpolation,@justOtherCurlyBraces,justIndentError
syn region justStringInShebangBody start=/\v\\@1<!'/ end=/'/ contained contains=justLineContinuation,justInterpolation,@justOtherCurlyBraces,justShebangIndentError
syn region justStringInShebangBody start=/\v\\@1<!"/ skip=/\v\\@1<!\\"/ end=/"/ contained contains=justLineContinuation,justInterpolation,@justOtherCurlyBraces,justShebangIndentError

syn match justStringEscapeSequence '\v\\[tnr"\\]' contained

syn match justAssignmentOperator ":=" contained

syn match justParameter "\v\s\zs%(%([*+]\s*)?%(\$\s*)?|\$\s*[*+]\s*)[a-zA-Z_][a-zA-Z0-9_-]*%(\s*\=\s*)?"
      \ transparent contained
      \ contains=justName,justVariadicPrefix,justParamExport,justParameterOperator,justVariadicPrefixError
syn match justParameterOperator "\V=" contained
syn match justVariadicPrefix "\v\s@1<=[*+]%(\s*\$?\s*[a-zA-Z_])@=" contained
syn match justParamExport '\V$' contained
syn match justVariadicPrefixError "\v\$\s*[*+]" contained
syn match justParameterError "\v%(%(\=\s*[a-zA-Z_][a-zA-Z0-9_-]*|[^a-zA-Z0-9_=*+$[:space:]-])\s+)@<=%(%([+*$]+\s*)*[a-zA-Z_][a-zA-Z0-9_-]*)@>%(\s*\=)@!" contained

syn match justRecipeAt "^@" contained
syn match justRecipeColon ":" contained

syn match justRecipeAttr '^\v\[\s*%(no-%(cd|exit-message)|linux|macos|unix|windows|private)%(\s*,\s*%(no-%(cd|exit-message)|linux|macos|unix|windows|private))*\s*\]'

syn match justRecipeDeclSimple "\v^\@?[a-zA-Z_][a-zA-Z0-9_-]*%(\s*:\=@!)@="
      \ transparent contains=justRecipeName
      \ nextgroup=justRecipeNoDeps,justRecipeDeps

syn region justRecipeDeclComplex start="\v^\@?[a-zA-Z_][a-zA-Z0-9_-]*\s+%([+*$]+\s*)*[a-zA-Z_]" end="\v%(:\=@!)@=|$"
      \ transparent
      \ contains=justRecipeName,justParameter,justParameterError,justRecipeParenDefault,@justAllStrings
      \ nextgroup=justRecipeNoDeps,justRecipeDeps

syn match justRecipeName "\v^\@?[a-zA-Z_][a-zA-Z0-9_-]*" transparent contained contains=justRecipeAt,justFunction

syn region justRecipeParenDefault
      \ matchgroup=justRecipeDepParamsParen start='\v%(\=\s*)@<=\(' end='\v\)%(\s+%([$*+]+\s*)?[a-zA-Z_]|:)@='
      \ contained
      \ contains=@justExpr

syn match justRecipeSubsequentDeps '&&' contained

syn match justRecipeNoDeps '\v:\s*\n|:#@=|:\s+#@='
      \ transparent contained
      \ contains=justRecipeColon
      \ nextgroup=justPreBodyComment,@justBodies
syn region justRecipeDeps start="\v:\s*%([a-zA-Z_(]|\&\&)" end="\v.#@=|\n"
      \ transparent contained
      \ contains=justFunction,justRecipeColon,justRecipeSubsequentDeps,justRecipeParamDep
      \ nextgroup=justPreBodyComment,@justBodies

syn region justRecipeParamDep contained transparent
      \ start="("
      \ matchgroup=justRecipeDepParamsParen end=")"
      \ contains=justRecipeDepParamsParen,@justExpr
syn match justRecipeDepParamsParen '\v\(\s*[a-zA-Z_][a-zA-Z0-9_-]*' contained contains=justFunction

syn keyword justBoolean true false contained

syn match justAssignment "\v^[a-zA-Z_][a-zA-Z0-9_-]*\s*:\=" transparent contains=justAssignmentOperator

syn match justSet '\v^set\s@=' contained
syn match justSetKeywords "\v%(allow-duplicate-recipes|dotenv-load|export|fallback|ignore-comments|positional-arguments|tempdir|shell|windows-shell)" contained
syn match justSetDeprecatedKeywords 'windows-powershell' contained
syn match justBooleanSet "\v^set\s+%(allow-duplicate-recipes|dotenv-load|export|fallback|ignore-comments|positional-arguments|windows-powershell)%(\s*:\=\s*%(true|false))?$"
      \ contains=justSet,justSetKeywords,justSetDeprecatedKeywords,justAssignmentOperator,justBoolean
      \ transparent

syn match justStringSet '\v^set\s+%(tempdir)\s*:\=\s*%(['"])@=' transparent contains=justSet,justSetKeywords,justAssignmentOperator

syn region justShellSet
      \ start=/\v^set\s+%(windows-)?shell\s*:\=\s*\[/
      \ end="]"
      \ contains=justSet,justSetKeywords,justAssignmentOperator,justString,justRawString,justNoise,justSetError
      \ transparent skipwhite

syn match justSetError '\v%(%(\[|,)%(\s|\n)*)@<=[^'"\][:space:]][^,\][:space:]]*|\[%(\s|\n)*\]' contained

syn match justAlias '\v^alias\s@=' contained
syn match justAliasDecl "\v^alias\s+[a-zA-Z_][a-zA-Z0-9_-]*\s*:\=\s*"
      \ transparent
      \ contains=justAlias,justFunction,justAssignmentOperator
      \ nextgroup=justAliasRes
syn match justAliasRes '\v[a-zA-Z_][a-zA-Z0-9_-]*\s*%(#@=|$)' contained transparent contains=justFunction

syn match justExportedAssignment "\v^export\s+[a-zA-Z_][a-zA-Z0-9_-]*\s*:\=" transparent
      \ contains=justExport,justAssignmentOperator

syn match justExport '\v^export\s@=' contained

syn keyword justConditional if else

syn match justLineLeadingSymbol "\v^%(\\\n)@3<!\s\s*\zs%(\@-|-\@|\@|-)"
syn match justLineContinuation "\\$" contained

syn region justBody
      \ start=/\v^%( +|\t+)%(#!)@!%(\@-|-\@|\@|-)?\S/
      \ skip='\\\n' end="\v\n\ze%(\n|\S)"
      \ contains=justInterpolation,@justOtherCurlyBraces,justLineLeadingSymbol,justLineContinuation,justComment,justStringInsideBody,justIndentError
      \ contained

syn region justShebangBody
      \ start="\v^%( +|\t+)#!"
      \ skip='\\\n' end="\v\n\ze%(\n|\S)"
      \ contains=justInterpolation,@justOtherCurlyBraces,justLineContinuation,justComment,justShebang,justStringInShebangBody,justShebangIndentError
      \ contained

syn cluster justBodies contains=justBody,justShebangBody

syn match justIndentError '\v^%(\\\n)@3<!%( +\zs\t|\t+\zs )\s*'
syn match justShebangIndentError '\v^ +\zs\t\s*'

syn region justInterpolation matchgroup=justInterpolationDelim start="\v\{\{%([^{])@=" end="}}" contained
      \ contains=justName,@justExprBase,@justBuiltInFunctionsInInterp

syn match justBadCurlyBraces '\v\{{3}\ze[^{]' contained
syn match justCurlyBraces '\v\{{4}' contained
syn match justBadCurlyBraces '\v\{{5}\ze[^{]' contained
syn cluster justOtherCurlyBraces contains=justCurlyBraces,justBadCurlyBraces

syn region justBuiltInFunctionWithArgs
      \ transparent end=')'
      \ matchgroup=justFunction start="\v%(absolute_path|c%(apitalize|lean)|e%(nv_var%(_or_default)?|xtension)|file_%(name|stem)|join|kebabcase|lowerca%(melca)?se|pa%(rent_directory|th_exists)|quote|replace|s%(h%(a256%(_file)?|outy%(kebab|snake)case)|nakecase)|t%(itlecase|rim%(_%(end|start)%(_match%(es)?)?)?)|upperca%(melca)?se|without_extension)%(\s*\()@="
      \ matchgroup=justUserDefinedError start="\verror%(\s*\()@="
      \ matchgroup=justBuiltInFunctionsError start="\v[a-zA-Z_][a-zA-Z0-9_-]*\s*\("
      \ contains=justNoise,@justExpr

syn region justBuiltInFuncWithArgsInInterp
      \ transparent end=')'
      \ matchgroup=justFunction start="\v%(absolute_path|c%(apitalize|lean)|e%(nv_var%(_or_default)?|xtension)|file_%(name|stem)|join|kebabcase|lowerca%(melca)?se|pa%(rent_directory|th_exists)|quote|replace|s%(h%(a256%(_file)?|outy%(kebab|snake)case)|nakecase)|t%(itlecase|rim%(_%(end|start)%(_match%(es)?)?)?)|upperca%(melca)?se|without_extension)%(\s*\()@="
      \ matchgroup=justUserDefinedError start="\verror%(\s*\()@="
      \ matchgroup=justBuiltInFunctionsError start="\v[a-zA-Z_][a-zA-Z0-9_-]*\s*\("
      \ contained
      \ contains=justNoise,@justExprBase,@justBuiltInFunctionsInInterp,justName

syn match justBuiltInFunctionZeroArgs "\v%(arch|invocation_directory%(_native)?|just%(_executable|file%(_directory)?)|os%(_family)?|uuid)\s*\(%(\s|\n)*\)"
      \ transparent contains=justFunction

syn region justReplaceRegex
      \ transparent end=')'
      \ matchgroup=justFunction start='\vreplace_regex%(\s*\()@='
      \ contains=justNoise,@justExpr,justRegexReplacement
syn region justReplaceRegexInInterp
      \ transparent end=')'
      \ matchgroup=justFunction start='\vreplace_regex%(\s*\()@='
      \ contained
      \ contains=justNoise,@justExprBase,justRegexReplacement,@justBuiltInFunctionsInInterp,justName

syn match justBuiltInFunctionsError "\v%(arch|invocation_directory%(_native)?|just%(_executable|file%(_directory)?)|os%(_family)?|uuid)\s*\(%(\s|\n)*%([^)[:space:]]%(\s|\n)*)+\)"

syn cluster justBuiltInFunctions contains=justBuiltInFunctionZeroArgs,justBuiltInFunctionWithArgs,justReplaceRegex,justBuiltInFunctionsError
syn cluster justBuiltInFunctionsInInterp contains=justBuiltInFunctionZeroArgs,justBuiltInFuncWithArgsInInterp,justReplaceRegexInInterp,justBuiltInFunctionsError

syn match justOperator "\v%(\=[=~]|!\=|[+/])"

syn cluster justExprBase contains=@justAllStrings,justConditional,justOperator
syn cluster justExpr contains=@justExprBase,@justBuiltInFunctions,justBuiltInFunctionArgs,justReplaceRegex

syn match justInclude "^!include\s\+.*$"

hi def link justAlias                 Statement
hi def link justAssignmentOperator    Operator
hi def link justBacktick              Special
hi def link justBadCurlyBraces        Error
hi def link justBody                  Number
hi def link justBoolean               Boolean
hi def link justBuiltInFunctionsError Error
hi def link justComment               Comment
hi def link justCommentTodo           Todo
hi def link justConditional           Conditional
hi def link justCurlyBraces           Special
hi def link justExport                Statement
hi def link justFunction              Function
hi def link justInclude               Include
hi def link justIndentError           Error
hi def link justInterpolation         Normal
hi def link justInterpolationDelim    Delimiter
hi def link justLineContinuation      Special
hi def link justLineLeadingSymbol     Special
hi def link justName                  Identifier
hi def link justOperator              Operator
hi def link justParameterError        Error
hi def link justParameterOperator     Operator
hi def link justParamExport           Statement
hi def link justRawString             String
hi def link justRawStrRegexRepl       String
hi def link justRecipeAt              Special
hi def link justRecipeAttr            Type
hi def link justRecipeColon           Operator
hi def link justRecipeDepParamsParen  Delimiter
hi def link justRecipeSubsequentDeps  Operator
hi def link justRegexCapture          Constant
hi def link justSet                   Statement
hi def link justSetDeprecatedKeywords Underlined
hi def link justSetError              Error
hi def link justSetKeywords           Keyword
hi def link justShebang               SpecialComment
hi def link justShebangBody           Number
hi def link justShebangIndentError    Error
hi def link justString                String
hi def link justStringEscapeSequence  Special
hi def link justStringInShebangBody   String
hi def link justStringInsideBody      String
hi def link justStringRegexRepl       String
hi def link justUserDefinedError      Exception
hi def link justVariadicPrefix        Statement
hi def link justVariadicPrefixError   Error
