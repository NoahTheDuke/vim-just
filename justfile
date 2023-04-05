# Do not prevent local external justfile recipes from being run from cwd within the repo
set fallback

rq := quote(justfile_directory())

synpreview_homedir := env_var_or_default('TMPDIR', '/tmp') / '_vim-just-preview-home.' + replace(uuid(), '-', '')

@_default:
	just --list

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
