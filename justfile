# Do not prevent local external justfile recipes from being run from cwd within the repo
set fallback

rq := quote(justfile_directory())

synpreview_homedir := env_var_or_default('TMPDIR', '/tmp') / '_vim-just-preview-home.' + replace(uuid(), '-', '')

@_default:
	just -f {{quote(justfile())}} --list

# preview JUSTFILE in Vim with syntax file from this repository
[no-cd]
preview JUSTFILE='': _vim_preview_home && _clean_vim_preview_home
	HOME={{quote(synpreview_homedir)}} \
	  vim {{if JUSTFILE == '' { '-c "set filetype=just"' } else { quote(JUSTFILE) } }}

# preview JUSTFILE in GVim with syntax file from this repository
[no-cd]
gpreview JUSTFILE='': _vim_preview_home && _clean_vim_preview_home
	HOME={{quote(synpreview_homedir)}} \
	  gvim -f {{if JUSTFILE == '' { '-c "set filetype=just"' } else { quote(JUSTFILE) } }}

# preview JUSTFILE in Neovim with syntax file from this repository
[no-cd]
npreview JUSTFILE='': && _clean_vim_preview_home
	#!/bin/bash
	mkdir -p {{quote(synpreview_homedir / '.config/nvim/pack/just/start')}}
	mkdir -p {{quote(synpreview_homedir / '.local/share/nvim/site/pack')}}
	ln -s {{rq}} {{quote(synpreview_homedir / '.config/nvim/pack/just/start/vim-just')}}
	for c in ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/{colors,init.vim,init.lua,lua,plugin};do \
	  test -e "$c" && ln -vs "$c" {{quote(synpreview_homedir / '.config/nvim')}}; \
	done
	for c in ${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/packer;do
	  # copy instead of symlink in case we will remove an existing copy of vim-just
	  test -e "$c" && cp -pvR "$c" {{quote(synpreview_homedir / '.local/share/nvim/site/pack')}};
	done
	# remove any existing installation of vim-just from the temporary home
	find {{quote(synpreview_homedir / '.local/share')}} -iname vim-just -exec rm -fvR {} +
	HOME={{quote(synpreview_homedir)}} \
	  XDG_CONFIG_HOME={{quote(synpreview_homedir / '.config')}} \
	  XDG_DATA_HOME={{quote(synpreview_homedir / '.local/share')}} \
	  nvim -c 'syntax on' \
	    {{if JUSTFILE == '' { '-c "set filetype=just"' } else { quote(JUSTFILE) } }}

_vim_preview_home: _clean_vim_preview_home
	mkdir -p {{quote(synpreview_homedir / '.vim/pack/just/start')}}
	ln -s {{rq}} {{quote(synpreview_homedir / '.vim/pack/just/start/vim-just')}}
	for c in ~/.vim/colors ~/.vim/vimrc ~/.vim/gvimrc;do \
	  test -e "$c" && ln -vs "$c" {{quote(synpreview_homedir / '.vim')}}; \
	done
_clean_vim_preview_home:
	rm -fvR {{quote(synpreview_homedir)}}


update-last-changed *force:
	#!/bin/bash
	for f in $(find * -name just.vim);do
	  gitrev="$(git log -n 1 --format='format:%H' -- "$f")"
	  if [[ {{quote(force)}} != *"$f"* ]];then
	    git show "$gitrev" | grep -q -P -i '^\+"\s*Last\s+Change:' && continue
	  fi
	  lastchange="$(git show -s "$gitrev" --format='%cd' --date='format:%Y %b %d')"
	  echo -e "$f -> Last Change: $lastchange"
	  sed --in-place -E -e "s/(^\"\s*Last\s+Change:\s+).+$/\\1${lastchange}/g" "$f"
	done



# Some functions are intentionally omitted from these lists because they're handled as special cases:
#  - error
#  - replace_regex
functionsWithArgs := '''
  absolute_path
  capitalize
  clean
  env
  env_var
  env_var_or_default
  extension
  file_name
  file_stem
  join
  kebabcase
  lowercamelcase
  lowercase
  parent_directory
  path_exists
  quote
  replace
  sha256
  sha256_file
  shoutykebabcase
  shoutysnakecase
  snakecase
  titlecase
  trim
  trim_end
  trim_end_match
  trim_end_matches
  trim_start
  trim_start_match
  trim_start_matches
  uppercamelcase
  uppercase
  without_extension
'''
zeroArgFunctions := '''
  arch
  invocation_directory
  invocation_directory_native
  just_executable
  justfile
  justfile_directory
  num_cpus
  os
  os_family
  uuid
'''

# generate an optimized Vim-style "very magic" regex snippet from a list of literal strings to match
optrx +strings:
	#!/usr/bin/env python3
	vparam = ''{{quote(strings)}}''
	import collections
	strings_list = vparam.split('|') if '|' in vparam else vparam.strip().split()
	charByPrefix=dict()
	for f in strings_list:
	  if len(f) < 1: continue
	  g=collections.deque(f)
	  p=charByPrefix
	  while len(g):
	    if g[0] not in p: p[g[0]] = dict()
	    p=p[g.popleft()]
	  p[''] = dict()
	def recursive_coalesce(d, addGrouping=False):
	  o=''
	  l = collections.deque(d.keys())
	  # Ensure empty string is at the end
	  if '' in l and l[-1] != '':
	    l.remove('')
	    l.append('')
	  while len(l):
	    c = l.popleft()
	    o += c
	    if len(d[c]) > 1:
	      o += recursive_coalesce(d[c], True)
	    else:
	      if len(d[c]) == 1:
	        o += recursive_coalesce(d[c])
	    if len(l):
	      o += '|'
	  # Do all items in this group have a common suffix?
	  ss=o.split('|')
	  if len(ss) > 1:
	    commonEnd = ''
	    tryCommonEnd = ss[0][:]
	    while len(tryCommonEnd):
	      c=0
	      for j in ss:
	        c += int(j.endswith(tryCommonEnd))
	      if c == len(ss):
	        commonEnd = tryCommonEnd
	        break
	      tryCommonEnd=tryCommonEnd[1:]
	    if not(commonEnd in ('', ')?')):
	      o = '%(' + ('|'.join(map(lambda s: s[:s.rfind(commonEnd)], ss))) + ')' + commonEnd
	    elif addGrouping:
	      o = f'%({o})'
	  return o.replace('|)', ')?')
	print(recursive_coalesce(charByPrefix))

# run optrx on a variable from this justfile
@optrx_var var:
	just -f {{quote(justfile())}} optrx "$(just -f {{quote(justfile())}} --evaluate {{var}})"
