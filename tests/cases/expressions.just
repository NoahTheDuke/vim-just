xdg_cache := cache_directory()
xdg_config := config_directory()
xdg_config_local := config_local_directory()
xdg_data := data_directory()
xdg_data_local := data_local_directory()
xdg_executable := executable_directory()
xdg_home := home_directory()

mydir := justfile_dir()
invoked_from := invocation_dir_native()

random1 := choose('10', HEXLOWER + replace_regex(HEXUPPER, '\d+', ''))

example_url := 'https://foo.example/?parameter=' + encode_uri_component(
  prepend('/', append('/', 'foo bar baz ' + HEX))
)

shell_expanded1 := x'$SHELL -c '
shell_expanded2 := x"${SHELL:-/bin/sh} -c "
shell_expanded3 := x'''
  $_'''
shell_expanded4 := x"""
  ${FOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO:-foo\r\n
  bar
     baz}
  $DIS\
  PLAY
  Foo
"""
shell_expanded5 := x'''
  ${FOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO:-foo\r\n
  bar
     baz}
'''
shell_expanded6 := x'$$$$not_an_env_var $$$${also_not_an_env_var}'
shell_expanded7 := x'''
  ${FOOOOOOOOOOOOOOOOO:-bar \
  baz
  }
'''
shell_expanded8 := x"""
  $\
  $\
  $\
  {\
  F\
  O\
  O\
  :\
  -\
  f\
  o\
  o\
  }\
"""

_true := assert('1' != '0', '1 is not 0')

shell_command := shell('echo "$@"', _true, random1)

this_source := source_directory() + "\n -> " + source_file()
current_module := module_directory() + "\n -> " + module_file()

unexport QT_QPA_PLATFORMTHEME

now := datetime('%Y-%m-%d %H:%M:%S %Z')
now_utc := datetime_utc('%Y-%m-%d %H:%M:%S %Z')

[private]
hidden := 'foo'
not_hidden := '-' + hidden

u_escape := "test \u{1F916} test"
u_escape_triple_quoted := """
  test
  \u{1f9Ea}
  test
"""
u_escape_shell_expanded := x"shell ${FOO:-(\u{1f41a})} shell"
u_escape_shell_expanded_name := x"""
  TERM=${\u{000054}\u{00045}\u{0052}\u{04d}}"""
u_escape_in_replace_regex := replace_regex('foo', '^.', "\u{46}")
not_u_escape := '\u{1F916}'
