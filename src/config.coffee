# Modules
fs = require 'fs'
colors = require './colors'

# Vendors
_ = require 'lodash-node'

# Class Definition
class Config
	_defaults = {}
	configFile = 'config.json'
	constructor: (options = {})->
		_defaults = _.merge(_defaults, options.defaults) if options.defaults
		configFile = options.configFile if options.configFile
		_setConfig()

	get: (prop="")->
		_config

	# Retrieve parameters
	# Find and read config JSON
	# Store the JSON
	_config = {}
	_setConfig = ->
		_config = _getConfig()
	_getConfig = ->
		args = _getArgs()
		config = false
		if _.isEmpty(args) and not fs.existsSync(configFile)
			err = 'config.coffe: No config file found'
			console.log err.error
			throw new Error err
		else if args and fs.existsSync(args[0])
			config = _readJSON args[0]
		else if fs.existsSync(configFile)
			config = _readJSON configFile
		config
	_getArgs = ->
		args = _.cloneDeep(process.argv).splice(0,2)
	_readJSON = (config)->
		fileContents = fs.readFileSync config, { encoding: 'utf8' }
		JSON.parse fileContents

module.exports = Config