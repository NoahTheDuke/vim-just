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
* Rust ([simple/recommended installation instructions](https://www.rust-lang.org/tools/install); for detailed and alternative installation instructions see [here](https://forge.rust-lang.org/infra/other-installation-methods.html))

Run `just deps` to install the cargo dev dependencies, which right now is only
[`cargo-watch`](https://crates.io/crates/cargo-watch).

### Test Suite

`vim-just` includes automated tests of its syntax highlighting and filetype detection.
Running the tests invokes Cargo to build and run the project, which
is a simple test-runner in the `main` fn.

To run the syntax highlighting tests, run `just run` in tests/.
If you want to run only a subset of the syntax highlighting tests,
you can pass an optional regex parameter to `just run` matching the filenames you want to include:

```bash
# run only the 'kitchen-sink.just' syntax highlighting test
$ just run kitchen-sink
...
test kitchen-sink…
ok

# run the syntax highlighting tests with base filenames matching the regex ^\w+$
$ just run '^\w+$'
...
test comment…
ok
test deprecated_obsolete…
ok
test invalid…
ok
test set…
ok
test tricky…
ok
```

Note that the `.just` extension is trimmed off before matching against the regex.

To run the filetype detection tests, run `just ftdetect` in tests/.

If you're going to do more than a simple change, I recommend calling `just watch` in tests/,
which will watch for any changes in the whole repo and re-run the test suite.
By default, it will run the syntax highlighting tests.
`just watch` accepts up to two parameters to customize which tests to watch:

```bash
# watch all syntax highlighting tests (default)
$ just watch

# watch ftdetect tests
$ just watch ftdetect

# watch all tests
$ just watch ftdetect run

# watch syntax highlighting tests with filenames matching the regex ^r.*s$
$ just watch run '^r.*s$'
```
