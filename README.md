# Vim Just Syntax

Vim syntax files for [justfiles](https://github.com/casey/just).

## Installation

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'NoahTheDuke/vim-just'
```

### [Pathogen](https://github.com/tpope/vim-pathogen)

```bash
cd ~/.vim/bundle
git clone https://github.com/NoahTheDuke/vim-just.git
```

### [Vim8 Package](https://vimhelp.org/repeat.txt.html#packages)

```bash
cd ~/.vim/pack/YOUR-NAMESPACE-HERE/start/
git clone https://github.com/NoahTheDuke/vim-just.git
```

----------

### Updating `git clone` based installations

Run the same `cd` command as in the relevant installation instructions, then:

```bash
cd vim-just
git pull --tags --verbose
```

#### Old `git clone` based installations

In late March 2023, development was moved from `master` branch to `main` branch, and `master` is no longer maintained.  Updating installations that used a `git clone` prior to these changes requires some additional one-time steps, run **after** the normal update procedure:

```bash
git checkout main
git branch -d master || git branch --unset-upstream master
git remote set-head origin -a
git remote prune origin
```

Now future updates can again be obtained normally.

----------

## Contributing & Development

Make some changes, open a PR, easy-peasy. I like to manually apply PRs, so don't be
surprised if I close your PR while pushing your authored commit directly to main.

### Prerequisites

* just (of course, lol)
* [colordiff](https://www.colordiff.org/)
* Rust ([simple/recommended installation instructions](https://www.rust-lang.org/tools/install); for detailed and alternative installation instructions see [here](https://forge.rust-lang.org/infra/other-installation-methods.html))

Run `just deps` to install the cargo dev dependencies, which right now is only
[`cargo-watch`](https://crates.io/crates/cargo-watch).

### Test Suite

To run the tests, run `just run` in tests/. Cargo will build and run the project, which
is a simple test-runner in the `main` fn. If you're going to do more than a simple
change, I recommend calling `just watch` in tests/, which will watch for any changes in
the whole repo and re-run the test suite. If you want to only run or watch a single test file, you
can specify the name by passing an argument to `run` or `watch`: `just run
recipe-dependency`.
