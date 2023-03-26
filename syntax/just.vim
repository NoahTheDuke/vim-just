" Vim syntax file
" Language:	Justfile
" Maintainer:	Noah Bogart <noah.bogart@hey.com>
" URL:		https://github.com/NoahTheDuke/vim-just.git
" Last Change:	2021 May 19

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'just'
syn sync minlines=60 maxlines=200

syn match justNoise ","

syn match justComment "\v#([^!].*)?$" contains=@Spell,justCommentTodo
syn keyword justCommentTodo TODO FIXME XXX contained
syn match justShebang "#!.*$" contains=justInterpolation
syn match justName "[a-zA-Z_][a-zA-Z0-9_-]*" contained
syn match justFunction "[a-zA-Z_][a-zA-Z0-9_-]*" contained

syn region justBacktick start=/`/ skip=/\./ end=/`/
syn region justRawString start=/'/ skip=/\./ end=/'/
syn region justString start=/"/ skip=/\.\|\\\\\|\\"/ end=/"/ contains=justNextLine,justStringEscapeSequence
syn cluster justAllStrings contains=justBacktick,justRawString,justString

syn region justStringInsideBody start=/'/ skip=/\v\{\{.*\}\}/ end=/'/ contained contains=justNextLine,justInterpolation,justCurlyBraces
syn region justStringInsideBody start=/"/ skip=/\v\{\{.*\}\}/ end=/"/ contained contains=justNextLine,justInterpolation,justCurlyBraces

syn match justStringEscapeSequence '\v\\[tnr"\\]' contained

syn match justAssignmentOperator ":=" contained

syn match justParameterOperator "=" contained
syn match justVariadicOperator "*\|+\|\$" contained
syn match justParameter "\v\s\zs%(\*|\+|\$)?[a-zA-Z_][a-zA-Z0-9_-]*\ze\=?" contained contains=justVariadicOperator,justParameterOperator

syn match justNextLine "\\\n\s*"
syn match justRecipeAt "^@" contained
syn match justRecipeColon "\v:" contained

syn match justRecipeAttr '^\[\s*\(no-\(cd\|exit-message\)\|linux\|macos\|unix\|windows\|private\)\(,\s*\(no-\(cd\|exit-message\)\|linux\|macos\|unix\|windows\|private\)\)*\s*\]'

syn region justRecipe
      \ matchgroup=justRecipeBody start="\v^\@?[a-zA-Z_]((:\=)@!.)*\ze:%(\s|\n)"
      \ matchgroup=justRecipeDeps end="\v:\zs.*\n"
      \ contains=justFunction,justRecipeColon

syn match justRecipeBody "\v^\@?[a-zA-Z_]((:\=)@!.)*\ze:%(\s|\n)"
      \ contains=justRecipeAt,justRecipeColon,justParameter,justParameterOperator,justVariadicOperator,@justAllStrings,justComment,justShebang

syn match justRecipeSubsequentDeps '&&' contained

syn match justRecipeDeps "\v:[^\=]?.*\n"
      \ contains=justComment,justFunction,justRecipeColon,justRecipeSubsequentDeps,justRecipeParamDep

syn region justRecipeParamDep contained transparent
      \ start="("
      \ matchgroup=justRecipeDepParamsParen start='\v(\(\s*[a-zA-Z_][a-zA-Z0-9_-]*)'
      \ end=")"
      \ contains=justRecipeDepParamsParen,justRecipeDepWithParams,@justAllStrings
syn match justRecipeDepParamsParen '\v(\(\s*[a-zA-Z_][a-zA-Z0-9_-]*|\))' contained contains=justRecipeDepWithParams
syn match justRecipeDepWithParams "\v\(\s*\zs[a-zA-Z_][a-zA-Z0-9_-]*" contained

syn match justBoolean "\v(true|false)" contained
syn match justKeywords "\v%(export|set)" contained

syn match justAssignment "\v^[a-zA-Z_][a-zA-Z0-9_-]*\s+:\=" transparent contains=justAssignmentOperator

syn match justSetKeywords "\v%(allow-duplicate-recipes|dotenv-load|export|fallback|ignore-comments|positional-arguments|tempdir|shell|windows-shell)" contained
syn match justSetDeprecatedKeywords 'windows-powershell' contained
syn match justSetDefinition "\v^set\s+%(allow-duplicate-recipes|dotenv-load|export|fallback|ignore-comments|positional-arguments|windows-powershell)%(\s+:\=\s+%(true|false))?$"
      \ contains=justSetKeywords,justSetDeprecatedKeywords,justKeywords,justAssignmentOperator,justBoolean
      \ transparent

syn match justSetBraces "\v[\[\]]" contained
syn region justSetDefinition
      \ start="\v^set\s+(windows-)?shell\s+:\=\s+\["
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
      \ contains=justKeywords,justAssignmentOperator,justBuiltinFunctions,@justAllStrings
      \ transparent oneline skipwhite

syn keyword justConditional if else
syn region justConditionalBraces start="\v[^{]\{[^{]" end="}" contained oneline contains=ALLBUT,justConditionalBraces

syn match justLineLeadingSymbol "\v^(\\\n)@<!\s\s*\zs(\@-|-\@|\@|-)"
syn match justLineContinuation "\\$" contained

syn region justBody start="\v^(^[A-Za-z_@-].*:%([^=].*)?\n)@<=%( |\t)+(\@-|-\@|\@|-)?\S" skip='\\\n' end="\v\n\ze%(\n|\S)"
      \ contains=justInterpolation,justCurlyBraces,justLineLeadingSymbol,justLineContinuation,justComment,justShebang,justStringInsideBody

syn match justIndentError '\v^%( +\t|\t+ )\s+'

syn region justInterpolation start="\v\{\{[^{]" end="}}" contained contains=ALLBUT,justInterpolation,justCurlyBraces,justFunction,justBody,justStringInsideBody

syn match justCurlyBraces '\v\{{4}' contained

syn match justBuiltInFunctions "\v%(absolute_path|arch|capitalize|clean|env_var_or_default|env_var|error|extension|file_name|file_stem|invocation_directory(_native)?|join|just_executable|justfile_directory|justfile|kebabcase|lowercamelcase|lowercase|os_family|os|parent_directory|path_exists|quote|replace_regex|replace|sha256_file|sha256|shoutykebabcase|shoutysnakecase|snakecase|titlecase|trim_end_matches|trim_end_match|trim_end|trim_start_matches|trim_start_match|trim_start|trim|uppercase|uppercamelcase|uuid|without_extension)\ze\(\)" contains=justBuiltInFunctions
syn region justBuiltInFunctions transparent matchgroup=justBuiltInFunctions start="\v%(absolute_path|arch|capitalize|clean|env_var_or_default|env_var|error|extension|file_name|file_stem|invocation_directory(_native)?|join|just_executable|justfile_directory|justfile|kebabcase|lowercamelcase|lowercase|os_family|os|parent_directory|path_exists|quote|replace_regex|replace|sha256_file|sha256|shoutykebabcase|shoutysnakecase|snakecase|titlecase|trim_end_matches|trim_end_match|trim_end|trim_start_matches|trim_start_match|trim_start|trim|uppercase|uppercamelcase|uuid|without_extension)\ze\(" end=")"
      \ oneline
      \ contains=@justAllStrings,justNoise,justBuiltInFunctions,justBuiltinFunctionsError

syn match justBuiltInFunctionsError "\v%(arch|os|os_family|invocation_directory(_native)?|justfile|justfile_directory|just_executable|uuid)\([^)]+\)"

syn match justOperator "\v%(\=\=|!\=|\=\~|\+)"

syn match justInclude "^!include\s\+.*$"

hi def link justAlias                 Statement
hi def link justAssignmentOperator    Operator
hi def link justBacktick              Special
hi def link justBody                  Number
hi def link justBoolean               Boolean
hi def link justBuiltInFunctions      Function
hi def link justBuiltInFunctionsError Error
hi def link justComment               Comment
hi def link justCommentTodo           Todo
hi def link justConditional           Conditional
hi def link justConditionalBraces     Delimiter
hi def link justCurlyBraces           Special
hi def link justExport                Statement
hi def link justFunction              Function
hi def link justInclude               Include
hi def link justIndentError           Error
hi def link justInterpolation         Delimiter
hi def link justKeywords              Statement
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
hi def link justRecipeAttr            Type
hi def link justRecipeBody            Function
hi def link justRecipeColon           Operator
hi def link justRecipeDepParamsParen  Delimiter
hi def link justRecipeDepWithParams   Function
hi def link justRecipeSubsequentDeps  Operator
hi def link justSetDefinition         Keyword
hi def link justSetKeywords           Keyword
hi def link justSetDeprecatedKeywords Underlined
hi def link justShebang               SpecialComment
hi def link justString                String
hi def link justStringEscapeSequence  Special
hi def link justStringInsideBody      String
hi def link justVariadicOperator      Operator
