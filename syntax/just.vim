" Vim syntax file
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just.git
" Last Change:	2023 Apr 12

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'just'
syn sync minlines=65 maxlines=200

syn match justNoise ","

syn match justComment "\v#([^!].*)?$" contains=@Spell,justCommentTodo
syn keyword justCommentTodo TODO FIXME XXX contained
syn match justShebang "#!.*$" contains=justInterpolation
syn match justName "[a-zA-Z_][a-zA-Z0-9_-]*" contained
syn match justFunction "[a-zA-Z_][a-zA-Z0-9_-]*" contained

syn match justPreBodyComment "\v\s*#([^!].*)?\n%(\t+| +)@=" transparent contained contains=justComment
      \ nextgroup=@justBodies skipnl

syn region justBacktick start=/`/ end=/`/
syn region justBacktick start=/```/ end=/```/
syn region justRawString start=/'/ end=/'/
syn region justRawString start=/'''/ end=/'''/
syn region justString start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=justNextLine,justStringEscapeSequence
syn region justString start=/"""/ skip=/\\\\\|\\"/ end=/"""/ contains=justNextLine,justStringEscapeSequence
syn cluster justAllStrings contains=justBacktick,justRawString,justString

syn match justRegexReplacement /\v,\_s*%('%([^']|\n)*'|'''%(\_.%(''')@!)*\_.?''')\_s*\)/me=e-1 transparent contained contains=@justExpr,@justStringsWithRegexCapture
syn match justRegexReplacement /\v,\_s*%("%([^"]|\\"|\n)*"|"""%(\_.%(""")@!)*\_.?""")\_s*\)/me=e-1 transparent contained contains=@justExpr,@justStringsWithRegexCapture
syn region justRawStrRegexRepl start=/\v'/ end=/'/ contained contains=justRegexCapture
syn region justRawStrRegexRepl start=/\v'''/ end=/'''/ contained contains=justRegexCapture
syn region justStringRegexRepl start=/\v"/ skip=/\\\\\|\\"/ end=/"/ contained contains=justNextLine,justStringEscapeSequence,justRegexCapture
syn region justStringRegexRepl start=/\v"""/ skip=/\\\\\|\\"/ end=/"""/ contained contains=justNextLine,justStringEscapeSequence,justRegexCapture
syn match justRegexCapture '\v%(\$@<!\$)@<!\$%([0-9A-Za-z_]+|\{[0-9A-Za-z_]+\})' contained
syn cluster justStringsWithRegexCapture contains=justRawStrRegexRepl,justStringRegexRepl

syn region justStringInsideBody start=/\v[^\\]'/ms=s+1 skip=/\v\{\{.*\}\}/ end=/'/ contained contains=justNextLine,justInterpolation,@justOtherCurlyBraces,justIndentError
syn region justStringInsideBody start=/\v[^\\]"/ms=s+1 skip=/\v\{\{.*\}\}|\\@<!\\"/ end=/"/ contained contains=justNextLine,justInterpolation,@justOtherCurlyBraces,justIndentError
syn region justStringInShebangBody start=/\v[^\\]'/ms=s+1 skip=/\v\{\{.*\}\}/ end=/'/ contained contains=justNextLine,justInterpolation,@justOtherCurlyBraces,justShebangIndentError
syn region justStringInShebangBody start=/\v[^\\]"/ms=s+1 skip=/\v\{\{.*\}\}|\\@<!\\"/ end=/"/ contained contains=justNextLine,justInterpolation,@justOtherCurlyBraces,justShebangIndentError

syn match justStringEscapeSequence '\v\\[tnr"\\]' contained

syn match justAssignmentOperator ":=" contained

syn match justParameter "\v\s\zs%(%([*+]\s*)?%(\$\s*)?|\$\s*[*+]\s*)[a-zA-Z_][a-zA-Z0-9_-]*%(\s*\=\s*)?"
      \ transparent contained
      \ contains=justName,justVariadicPrefix,justParamExport,justParameterOperator,justVariadicPrefixError
syn match justParameterOperator "\V=" contained
syn match justVariadicPrefix "\v\s@<=[*+]%(\s*\$?\s*[a-zA-Z_])@=" contained
syn match justParamExport '\V$' contained
syn match justVariadicPrefixError "\v\$\s*[*+]" contained

syn match justNextLine "\\\n\s*"
syn match justRecipeAt "^@" contained
syn match justRecipeColon ":" contained

syn match justRecipeAttr '^\[\s*\(no-\(cd\|exit-message\)\|linux\|macos\|unix\|windows\|private\)\(\s*,\s*\(no-\(cd\|exit-message\)\|linux\|macos\|unix\|windows\|private\)\)*\s*\]'

syn match justRecipeDeclSimple "\v^\@?[a-zA-Z_][a-zA-Z0-9_-]*%(\s*:\=@!)@="
      \ transparent contains=justRecipeName
      \ nextgroup=justRecipeNoDeps,justRecipeDeps

syn region justRecipeDeclComplex start="\v^\@?[a-zA-Z_][a-zA-Z0-9_-]*\s+%([+*$]+\s*)*[a-zA-Z_]" end="\v%(:\=@!)@=|$"
      \ transparent
      \ contains=justRecipeName,justParameter,justRecipeParenDefault,@justAllStrings
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
      \ matchgroup=justRecipeDepParamsParen start='\v(\(\s*[a-zA-Z_][a-zA-Z0-9_-]*)'
      \ end=")"
      \ contains=justRecipeDepParamsParen,justRecipeDepWithParams,@justExpr
syn match justRecipeDepParamsParen '\v(\(\s*[a-zA-Z_][a-zA-Z0-9_-]*|\))' contained contains=justRecipeDepWithParams
syn match justRecipeDepWithParams "\v\(\s*\zs[a-zA-Z_][a-zA-Z0-9_-]*" contained

syn match justBoolean "\v(true|false)" contained

syn match justAssignment "\v^[a-zA-Z_][a-zA-Z0-9_-]*\s+:\=" transparent contains=justAssignmentOperator

syn match justSet '\v^set\ze\s+' contained
syn match justSetKeywords "\v%(allow-duplicate-recipes|dotenv-load|export|fallback|ignore-comments|positional-arguments|tempdir|shell|windows-shell)" contained
syn match justSetDeprecatedKeywords 'windows-powershell' contained
syn match justBooleanSet "\v^set\s+%(allow-duplicate-recipes|dotenv-load|export|fallback|ignore-comments|positional-arguments|windows-powershell)%(\s+:\=\s+%(true|false))?$"
      \ contains=justSet,justSetKeywords,justSetDeprecatedKeywords,justAssignmentOperator,justBoolean
      \ transparent

syn match justStringSet '\v^set\s+%(tempdir)\s+:\=\s+%(['"])@=' transparent contains=justSet,justSetKeywords,justAssignmentOperator

syn region justShellSet
      \ start=/\v^set\s+(windows-)?shell\s+:\=\s+\[/
      \ end="]"
      \ contains=justSet,justSetKeywords,justAssignmentOperator,justString,justRawString,justNoise,justSetError
      \ transparent skipwhite

syn match justSetError '\v%(%(\[|,)%(\s|\n)*)@<=[^'"\][:space:]][^,\][:space:]]*|\[%(\s|\n)*\]' contained

syn region justAlias
      \ matchgroup=justAlias start="\v^alias\ze\s+[a-zA-Z_][a-zA-Z0-9_-]*\s+:\="
      \ end="$"
      \ contains=justFunction,justAssignmentOperator
      \ oneline skipwhite

syn match justExportedAssignment "\v^export\s+[a-zA-Z_][a-zA-Z0-9_-]*\s+:\="
      \ contains=justExport,justAssignmentOperator,@justExpr
      \ transparent oneline skipwhite

syn match justExport '\v^export\ze\s+' contained

syn keyword justConditional if else

syn match justLineLeadingSymbol "\v^(\\\n)@<!\s\s*\zs(\@-|-\@|\@|-)"
syn match justLineContinuation "\\$" contained

syn region justBody
      \ start=/\v^%( +|\t+)%(#!)@!(\@-|-\@|\@|-)?\S/
      \ skip='\\\n' end="\v\n\ze%(\n|\S)"
      \ contains=justInterpolation,@justOtherCurlyBraces,justLineLeadingSymbol,justLineContinuation,justComment,justStringInsideBody,justIndentError
      \ contained

syn region justShebangBody
      \ start="\v^%( +|\t+)#!"
      \ skip='\\\n' end="\v\n\ze%(\n|\S)"
      \ contains=justInterpolation,@justOtherCurlyBraces,justLineContinuation,justComment,justShebang,justStringInShebangBody,justShebangIndentError
      \ contained

syn cluster justBodies contains=justBody,justShebangBody

syn match justIndentError '\v^(\\\n)@<!%( +\zs\t|\t+\zs )\s*'
syn match justShebangIndentError '\v^ +\zs\t\s*'

syn region justInterpolation matchgroup=justInterpolationDelim start="\v\{\{%([^{])@=" end="}}" contained
      \ contains=ALLBUT,justInterpolation,@justOtherCurlyBraces,justFunction,@justBodies,justRegexReplacement,@justStringsWithRegexCapture,justStringInsideBody,justStringInShebangBody,justBuiltInFunctionArgs,justRecipeDepParamsParen,justVariadicPrefix,justParameter,justParamExport,justVariadicPrefixError

syn match justBadCurlyBraces '\v\{{3}\ze[^{]' contained
syn match justCurlyBraces '\v\{{4}' contained
syn match justBadCurlyBraces '\v\{{5}\ze[^{]' contained
syn cluster justOtherCurlyBraces contains=justCurlyBraces,justBadCurlyBraces

syn match justBuiltInFunctions "\v[0-9A-Za-z_]@<!%(absolute_path|arch|capitalize|clean|env_var_or_default|env_var|error|extension|file_name|file_stem|invocation_directory(_native)?|join|just_executable|justfile_directory|justfile|kebabcase|lowercamelcase|lowercase|os_family|os|parent_directory|path_exists|quote|replace_regex|replace|sha256_file|sha256|shoutykebabcase|shoutysnakecase|snakecase|titlecase|trim_end_matches|trim_end_match|trim_end|trim_start_matches|trim_start_match|trim_start|trim|uppercase|uppercamelcase|uuid|without_extension)%(\s*\()@=" contained

syn region justBuiltInFunctionArgs start='\v[0-9A-Za-z_]@<![0-9A-Za-z_]+%(replace_regex)@<!\s*\(' end=')' transparent
      \ contains=justNoise,@justExpr
syn region justBuiltInFuncArgsInInterp start='\v[0-9A-Za-z_]@<![0-9A-Za-z_]+%(replace_regex)@<!\s*\(' end=')' contained transparent
      \ contains=justNoise,@justExprBase,justBuiltInFuncArgsInInterp,justName

syn region justReplaceRegex start='\v[0-9A-Za-z_]@<!replace_regex\s*\(' end=')' transparent
      \ contains=justNoise,@justExpr,justRegexReplacement
syn region justReplaceRegexInInterp start='\v[0-9A-Za-z_]@<!replace_regex\s*\(' end=')' contained transparent
      \ contains=justNoise,@justExprBase,justRegexReplacement,justBuiltInFuncArgsInInterp,justReplaceRegexInInterp,justName

syn match justBuiltInFunctionsError "\v%(arch|os|os_family|invocation_directory(_native)?|justfile|justfile_directory|just_executable|uuid)\s*\(%([^)]|\n)*[^)[:space:]]+%([^)]|\n)*\)"

syn match justOperator "\v%(\=\=|!\=|\=\~|[+/])"

syn cluster justExprBase contains=@justAllStrings,justBuiltInFunctions,justBuiltInFunctionsError,justConditional,justOperator
syn cluster justExpr contains=@justExprBase,justBuiltInFunctionArgs,justReplaceRegex

syn match justInclude "^!include\s\+.*$"

hi def link justAlias                 Statement
hi def link justAssignmentOperator    Operator
hi def link justBacktick              Special
hi def link justBadCurlyBraces        Error
hi def link justBody                  Number
hi def link justBoolean               Boolean
hi def link justBuiltInFunctions      Function
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
hi def link justNextLine              Special
hi def link justOperator              Operator
hi def link justParameterOperator     Operator
hi def link justParamExport           Statement
hi def link justRawString             String
hi def link justRawStrRegexRepl       String
hi def link justRecipeAt              Special
hi def link justRecipeAttr            Type
hi def link justRecipeColon           Operator
hi def link justRecipeDepParamsParen  Delimiter
hi def link justRecipeDepWithParams   Function
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
hi def link justVariadicPrefix        Statement
hi def link justVariadicPrefixError   Error
