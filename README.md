# Vim Just Syntax

Vim syntax files for [justfiles](https://github.com/casey/just).

Works with Vim/GVim >= 8, Neovim >= 0.4.

## Installation

### [Vim8 Package](https://vimhelp.org/repeat.txt.html#packages)

```bash
cd ~/.vim/pack/YOUR-NAMESPACE-HERE/start/
git clone https://github.com/NoahTheDuke/vim-just.git
```

### With a plugin manager

#### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'NoahTheDuke/vim-just'
```

#### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "NoahTheDuke/vim-just",
  ft = { "just" },
}
```

### Third-party packages

For questions or issues when using these packages, contact the package's maintainer.

[![Packaging status](https://repology.org/badge/vertical-allrepos/vim:vim-just.svg)](https://repology.org/project/vim:vim-just/versions)

## Migrating old `git clone` based installations to `main`

In late March 2023, development was moved from `master` branch to `main` branch,
and `master` is no longer maintained.
Updating installations that used a `git clone` prior to these changes requires some
additional one-time steps:

```bash
git fetch
git checkout main
git branch -d master || git branch --unset-upstream master
git remote set-head origin -a
git remote prune origin
```

Now future updates can again be obtained normally.

## Contributing & Development

See [CONTRIBUTING.md](CONTRIBUTING.md).
