#Vendors
colors = require 'cli-color'

# Color Definitions
notice = colors.bgCyanBright.black
debug = colors.bgYellowBright.black
errorTitle = colors.bgRedBright.black
errorMsg = colors.redBright.bgBlack

# Class Definition
class Config
	defaults = {}
	constructor: (options = {})->
		defaults = _.merge options.defaults if options.defaults
		console.log notice('defaults'), defaults

module.exports = new Config