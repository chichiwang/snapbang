fs = require 'fs'
colors = require 'cli-color'

# Color definitions
notice = colors.bgCyanBright.black

main = ->
	console.log notice('INITIAL FILE')

exports.convert = main