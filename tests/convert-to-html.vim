set nobackup               " don't save backup files
set nowritebackup          " don't create backup files while editing
setlocal readonly          " no need to modify test case justfiles
set nofixeol               " don't add or remove trailing newlines

" define a color for every default syntax class
hi Boolean        ctermfg=7*
hi Character      ctermfg=7*
hi Comment        ctermfg=7*
hi Conditional    ctermfg=7*
hi Constant       ctermfg=7*
hi Debug          ctermfg=7*
hi Define         ctermfg=7*
hi Delimiter      ctermfg=7*
hi Error          ctermfg=7*
hi Exception      ctermfg=7*
hi Float          ctermfg=7*
hi Function       ctermfg=7*
hi Identifier     ctermfg=7*
hi Ignore         ctermfg=7*
hi Include        ctermfg=7*
hi Keyword        ctermfg=7*
hi Label          ctermfg=7*
hi Macro          ctermfg=7*
hi Normal         ctermfg=7*
hi Number         ctermfg=7*
hi Operator       ctermfg=7*
hi PreCondit      ctermfg=7*
hi PreProc        ctermfg=7*
hi Repeat         ctermfg=7*
hi Special        ctermfg=7*
hi SpecialChar    ctermfg=7*
hi SpecialComment ctermfg=7*
hi Statement      ctermfg=7*
hi StorageClass   ctermfg=7*
hi String         ctermfg=7*
hi Tag            ctermfg=7*
hi Todo           ctermfg=7*
hi Type           ctermfg=7*
hi Typedef        ctermfg=7*
hi Underlined     ctermfg=7*

" define a helper function to check whether a syntax group is cleared
" This is so different between Vim and versions of Neovim that we need platform-specific variants.
if exists("*hlget")
  " Vim
  function s:is_cleared(name)
    let l:chr_hlget = hlget(a:name)
    return len(l:chr_hlget) > 0 && l:chr_hlget[0]->has_key("cleared") && l:chr_hlget[0].cleared
  endfunction
elseif has("nvim") && exists("*nvim_get_hl")
  " Neovim >= 0.9
  function s:is_cleared(name)
    return len(nvim_get_hl(0, {"name": a:name})) == 0
  endfunction
else
  " old Neovim
  " fallback to checking name
  " this function is only ever passed canonical group name obtained from result of synIDtrans()
  " so if we get a name starting with 'just' it's an unlinked implementation detail of vim-just
  function s:is_cleared(name)
    return luaeval('string.len(_A) > 4 and string.sub(_A, 1, 4) == "just"', a:name)
  endfunction
endif

" convert justfile to HTML
function s:html(winid)
  let l:saved_wid = win_getid()
  call win_gotoid(a:winid)

  let l:has_eol = &eol

  let l:output = []

  let l:line_n = 1
  let l:line_max = line('$')

  while l:line_n <= l:line_max
    let l:line = getline(l:line_n)
    let l:last_name = ""
    let l:line_html = ""

    let l:chr_n = 0
    let l:chr = l:line[l:chr_n]
    let l:last_synid = hlID("cleared")
    while !empty(l:chr)
      let l:synid = synID(l:line_n, l:chr_n + 1, 1)
      let l:name = synIDattr(synIDtrans(l:synid), "name")
      if s:is_cleared(l:name)
        let l:name = ""
      endif

      if l:synid != l:last_synid
        if !empty(l:last_name)
          let l:line_html .= '</span>'
        endif
        if !empty(l:name)
          let l:line_html .= '<span class="' . l:name . '">'
        endif
      endif

      if l:chr == '&'
        let l:line_html .= '&amp;'
      elseif l:chr == '<'
        let l:line_html .= '&lt;'
      elseif l:chr == '>'
        let l:line_html .= '&gt;'
      elseif l:chr == "\t"
        let l:line_html .= '&Tab;'
      else
        let l:line_html .= l:chr
      endif

      let l:last_name = l:name
      let l:last_synid = l:synid

      let l:chr_n += 1
      let l:chr = l:line[l:chr_n]
    endwhile

    if !empty(l:last_name)
      let l:line_html .= '</span>'
    endif

    call add(l:output, l:line_html)
    let l:line_n += 1
  endwhile

  if l:has_eol
    call add(l:output, "")
  endif

  call win_gotoid(l:saved_wid)
  return l:output
endfunction

" perform HTML conversion in a new buffer and write HTML to output
let s:wid = win_getid()
new | set noeol | call append(1, s:html(s:wid)) | 1d | w! $OUTPUT

" quit!
qa!
