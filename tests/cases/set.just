set allow-duplicate-variables
set allow-duplicate-variables := true
set allow-duplicate-variables := false

set dotenv-load
set dotenv-load := true
set dotenv-load := false

set dotenv-override
set dotenv-override := true
set dotenv-override := false

set export
set export := true
set export := false

set lazy
set lazy := true
set lazy := false

set no-cd
set no-cd := true
set no-cd := false

set positional-arguments
set positional-arguments := true
set positional-arguments := false

set quiet
set quiet := true
set quiet := false

set shell := ["foo"]
set shell := ["foo",]
set shell := ["foo", "bar"]
set shell := ["foo", "bar",]
set shell := ['python3', '-c', """
import sys\nprint(sys.argv[1:])
"""

,	'''
prefix'''
]
set shell:=['bash',"-c"]
set shell := [x"$SHELL"]
set shell := [system_root + PATH_SEP + 'bin' / 'bash', '-euc']
set shell := [system_root + \
  PATH_SEP + 'bin' \
/ 'bash',
'-euc']

set windows-shell:=["powershell.exe", "-NoLogo", "-Command"]

set script-interpreter := ['/usr/bin/env', 'python3']

set fallback
set fallback := true
set fallback := false
set fallback:=false
set fallback:= true
set fallback :=false

# the trailing whitespace at the end of the following lines is intentional
set fallback 
set fallback := true 
set fallback := false 

set fallback # comment
set fallback := true # comment
set fallback := true# comment

set fallback := true \
  # comment

set fallback := false\
#comment

set tempdir := '/tmp'
set tempdir := """
/tmp"""
set tempdir:="/tmp"
set tempdir:= "/tmp"
set tempdir :='/tmp'
set tempdir := x'${XDG_CACHE_HOME:-/tmp}'
set tempdir := '/run/user' / user_id / 'just'
set tempdir := PATH_SEP + 't' + "m" + '''p'''

set dotenv-filename := "mydotenv"
set dotenv-path := '/tmp/dotenv'

set dotenv-required
set dotenv-required := true
set dotenv-required := false

set unstable
set unstable := true
set unstable := false

set working-directory := '/tmp'

set no-exit-message
set no-exit-message := true
set no-exit-message := false

set default-list
set default-list := true
set default-list := false

set default-script
set default-script := true
set default-script := false

set guards
set guards := true
set guards := false

set lists
set lists := true
set lists := false

set indentation := "	"
set indentation := "\t"
set indentation := "  "
set minimum-version := '1.58.0'
