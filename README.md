# Vim Just Syntax

Vim syntax files for [justfiles](https://github.com/casey/just). Nothing to note yet as
the project is young.

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

## Contributing & Development

Make some changes, open a PR, easy-peasy. I like to manually apply PRs, so don't be
surprised if I close your PR while pushing your authored commit directly to master.

### Prerequisites

* just (of course, lol)
* [colordiff](https://www.colordiff.org/)
* [Rust](https://www.rust-lang.org/)

If you don't have Rust installed, run `just install-rustup` in tests/. This will
download and install the latest version of the Rust toolchain, including Cargo, the Rust
package manager.

### Test Suite

To run the tests, run `just run` in tests/. Cargo will build and run the project, which
is a simple test-runner in the `main` fn. If you're going to do more than a simple
change, I recommend calling `just watch` in tests/, which will watch for any changes in
the whole repo and re-run the test suite. Because of the use of vim's built-in `TOhtml`,
the suite is rather slow, so if you want to only run or watch a single test file, you
can specify the name by passing an argument to `run` or `watch`: `just run
recipe-dependency`.
