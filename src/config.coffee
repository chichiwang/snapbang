# Modules
fs = require 'fs'
colors = require './colors'

# Vendors
_ = require 'lodash-node'

# Class Definition
class Config
	_defaults = {}
	constructor: (options = {})->
		_defaults = _.merge options.defaults if options.defaults
		console.log notice('_defaults'), _defaults

	_getOptions = ->
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
	_getParameters = ->
		args = _.cloneDeep(process.argv).splice(0,2)
	_getConfig = (config)->
		fileContents = fs.readFileSync config, { encoding: 'utf8' }
		JSON.parse fileContents

module.exports = Config