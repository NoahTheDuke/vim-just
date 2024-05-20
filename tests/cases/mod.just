mod foo

# the trailing whitespace at the end of the following line is intentional
mod foo 

mod foo "foo/justfile"

mod _foo-Foo \
  'foo/foo.just'

mod? foo

mod ? foo 'foo/justfile'

mod foo x'$FOO/justfile'
mod? foo x"$FOO/justfile"
