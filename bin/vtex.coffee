program = require 'commander'
pkg = require '../package.json'
PowerTool = require '../libs/powertool'

program.version pkg.version
	.usage 'COMMAND [options]'
	.option '-l, login', 'authenticate user'
	.option '-s, sync', 'syncronize application'
	.parse process.argv

try
	return new PowerTool program
catch error
	console.error error.message.red