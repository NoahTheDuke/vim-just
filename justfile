# Do not prevent local external justfile recipes from being run from cwd within the repo
set fallback

rq := quote(justfile_directory())

synpreview_homedir := env_var_or_default('TMPDIR', '/tmp') / '_vim-just-preview-home.' + replace(uuid(), '-', '')

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
	ln -s {{rq}} {{quote(synpreview_homedir / '.config/nvim/pack/just/start/vim-just')}}
	for c in ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/{colors,init.vim};do \
	  test -e "$c" && ln -vs "$c" {{quote(synpreview_homedir / '.config/nvim')}}; \
	done
	HOME={{quote(synpreview_homedir)}} XDG_CONFIG_HOME={{quote(synpreview_homedir / '.config')}} \
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
