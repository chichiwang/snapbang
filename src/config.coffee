# Node API
fs = require 'fs'

# Vendors
_ = require 'lodash-node'
colors = require 'cli-color'

# Color Definitions
notice = colors.bgCyanBright.black
debug = colors.bgYellowBright.black
errorTitle = colors.bgRedBright.black
errorMsg = colors.redBright.bgBlack

# Class Definition
class Config
	_defaults = {}
	constructor: (options = {})->
		_defaults = _.merge options.defaults if options.defaults
		console.log notice('_defaults'), _defaults

	getOptions = ->
		params = getParameters()
		options = false
		if _.isEmpty(params) and not fs.existsSync(Options.configFile)
			console.log errorTitle('Error:'), errorMsg('No config file found')
			throw new Error 'No config file found'
		else if params and fs.existsSync(params[0])
			options = getConfig params[0]
		else if fs.existsSync(Options.configFile)
			options = getConfig Options.configFile
		options
	getParameters = ->
		args = _.cloneDeep process.argv
		args.splice 0,2
		args

module.exports = Config