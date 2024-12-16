set unstable

[script: 'python3']
python_info:
	import platform
	print(platform.python_implementation(), platform.python_version())

[script('just', '-d', x'${PWD:-.}/', '-f')]
nested_justfile:
	foo:
		pwd

foo := 'foo' && '' || 'foo'
