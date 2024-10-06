Contributing
============

Thank you for your interest in contributing to `vim-just`!

## General

Any contribution intentionally submitted
for inclusion in the work by you shall be licensed as in [LICENSE](LICENSE),
without any additional terms or conditions.

## Pull Requests

Reviewing a change requires understanding the reason for the change.
To save time and avoid additional back-and-forth,
please include a descriptive rationale when submitting your PR.
If the changes have already been discussed in a `vim-just` issue,
this can simply be a link to the relevant issue.

We sometimes like to manually apply PRs, so don't be
surprised if we close your PR while pushing your authored commit directly to main.

Developer Documentation
=======================

## Conformance

Filetype detection and ftplugin settings follow `just` documentation without deviation.

Syntax highlighting targets how `just` actually behaves.
This means that if `just` accepts a syntax form, it's considered valid,
even if it's not documented directly.

## Test Suite

`vim-just` includes automated tests of its syntax highlighting and filetype detection.
Running the tests invokes Cargo to build and run the project, which
is a simple test-runner in the `main` fn.

### Prerequisites

* just (of course, lol)
* Rust ([simple/recommended installation instructions](https://www.rust-lang.org/tools/install); for detailed and alternative installation instructions see [here](https://forge.rust-lang.org/infra/other-installation-methods.html))

Run `just deps` to install the cargo dev dependencies, which right now is only
[Watchexec CLI](https://crates.io/crates/watchexec-cli).

### Running the tests

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
`just watch` accepts positional parameters to customize which tests to watch:

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

Unless otherwise specified, the test runner will run `vim` to perform the tests.
To test with Neovim or an alternative Vim installation,
the environment variable `TEST_VIM` can be set to the path of the executable:

```bash
# test Neovim
export TEST_VIM=nvim

# one-time run syntax highlighting tests with an alternative Vim executable
TEST_VIM=/opt/vim91/bin/vim just run
```

Vim and Neovim require slightly different invocation.
If the specified executable's
[`file_stem`](https://doc.rust-lang.org/std/path/struct.Path.html#method.file_stem)
contains "nvim", the test runner will treat it as Neovim.
Otherwise, the test runner will treat it as Vim.

### How the tests work

The test runners run Vim with a custom value of the `HOME` environment variable
and create a symlink such that the repository root directory is `~/.vim` to invoked Vim instances,
or `${XDG_CONFIG_HOME}/nvim` to invoked Neovim instances.

For each `*.just` file in `tests/cases/`, the syntax highlighting test runner opens it in Vim,
runs a Vim script to create HTML representation of the effective highlighting,
normalizes the result, and compares it to the corresponding .html file.
If they don't match, the diff will be printed.
They're effectively "snapshot" tests: at this stage of the syntax files,
this is how the given file should be highlighted.

The recommended way to update the syntax highlighting tests is
to run them and then copy-paste intentional parts of the
diff output into the relevant html files.

Filetype detection tests are documented in `tests/cases/ftdetect.yml`.

### About test cases

To assist with accuracy of `vim-just` syntax highlighting,
most of the test case justfiles are designed to be valid and runnable.

Running `just check-cases` in tests/ performs basic validity checking of all test case justfiles
except for files intentionally flagged as invalid.  The exceptions list is in the tests justfile.
