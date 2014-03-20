program = require 'commander'
pkg = require.main.require '../package'
PowerTool = require '../libs/powertool'

program.version pkg.version
	.usage 'COMMAND [options]'
	.option '-l, login', 'authenticate user'
	.option '-p, preview', 'preview application'
	.option '-s, session <command>', 'call \'session help\' for more information'
	.parse process.argv

try
	return new PowerTool program
catch error
	console.log error.red
