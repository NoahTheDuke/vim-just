Contributing
============

Make some changes, open a PR, easy-peasy. I like to manually apply PRs, so don't be
surprised if I close your PR while pushing your authored commit directly to main.

Any contribution intentionally submitted
for inclusion in the work by you shall be licensed as in [LICENSE](LICENSE),
without any additional terms or conditions.

Developer Documentation
=======================

## Test Suite

`vim-just` includes automated tests of its syntax highlighting and filetype detection.
Running the tests invokes Cargo to build and run the project, which
is a simple test-runner in the `main` fn.

### Prerequisites

* just (of course, lol)
* Rust ([simple/recommended installation instructions](https://www.rust-lang.org/tools/install); for detailed and alternative installation instructions see [here](https://forge.rust-lang.org/infra/other-installation-methods.html))

Run `just deps` to install the cargo dev dependencies, which right now is only
[`cargo-watch`](https://crates.io/crates/cargo-watch).

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
