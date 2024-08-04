set allow-duplicate-variables
set allow-duplicate-variables := true
set allow-duplicate-variables := false

set dotenv-load
set dotenv-load := true
set dotenv-load := false

set export
set export := true
set export := false

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

set dotenv-filename := "mydotenv"
set dotenv-path := '/tmp/dotenv'

set dotenv-required
set dotenv-required := true
set dotenv-required := false

set unstable
set unstable := true
set unstable := false

set working-directory := '/tmp'
