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

set windows-shell:=["powershell.exe", "-NoLogo", "-Command"]

set fallback
set fallback := true
set fallback := false
set fallback:=false
set fallback:= true
set fallback :=false

set tempdir := '/tmp'
set tempdir := """
/tmp"""
set tempdir:="/tmp"
set tempdir:= "/tmp"
set tempdir :='/tmp'

set dotenv-filename := "mydotenv"
set dotenv-path := '/tmp/dotenv'
