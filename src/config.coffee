`/*
 * Module: config.coffee
 * 0.0.0
 *
 * A module that retrieves and manages a configuration JSON.
 * Retrieves configuration JSON from a file.
 *
 * Copyright (c) 2014, Chi Wang
 * Licensed under the MIT license.
 */`

# Modules
fs = require 'fs'
colors = require './colors'

# Vendors
_ = require 'lodash-node'

# Class Definition
class Config
	_defaults = {}
	_config = {}
	_configFile = 'config.json'

	constructor: (options = {})->
		_defaults = _.merge(_defaults, options.defaults) if options.defaults
		_configFile = options.configFile if options.configFile
		_setConfig()
	# Get a config property
	get: (prop="")->
		# Parameter must be a string
		if not _.isString(prop)
			err = "config.coffee: parameter passed to get() must be a string"
			console.log err.error
			throw new Error err
		
		result = undefined
		# No property passed in, return entire config
		if _.isEmpty(prop)
			result = _config
		# Search config properties
		else
			propTree = prop.split('.')
			endOfPropTree = propTree.length-1
			config = _.cloneDeep _config
			for key, idx in propTree
				if idx is endOfPropTree
					result = _.cloneDeep(config[key]) if not _.isUndefined(config[key])
					break
				break if not _.isObject(config[key])
				config = config[key]
		result
	# Set a config property
	set: (prop, val)->
		# Must declare a property to set a value on
		if not _.isString(prop)
			err = "config.coffee: set() method must be passed a valid property name"
			console.log err.error
			throw new Error err
		# Empty string passed in, replace root config object
		assigned = false
		if prop is ""
			_config = val
			assigned = true
		# Search the config properties to set the value 
		else
			propTree = prop.split('.')
			endOfPropTree = propTree.length-1
			config = _config
			for key, idx in propTree
				if idx is endOfPropTree
					assigned = true
					config[key] = val
					break
				break if not _.isObject(config[key])
				config = config[key]
			# Could not assign value
			if assigned is false
				err = "config.coffee: Unable to set "+prop+"to "+val
				console.log err.error
				throw new Error err
		assigned

	# Retrieve parameters
	# Find and read config JSON
	# Store the JSON
	_setConfig = ->
		_config = _.merge _defaults, _getConfig()
	_getConfig = ->
		args = _getArgs()
		config = false
		if _.isEmpty(args) and not fs.existsSync(_configFile)
			err = 'config.coffe: No config file found'
			console.log err.error
			throw new Error err
		else if args and fs.existsSync(args[0])
			config = _readJSON args[0]
		else if fs.existsSync(_configFile)
			config = _readJSON _configFile
		config
	_getArgs = ->
		args = _.cloneDeep(process.argv).splice(0,2)
	_readJSON = (config)->
		fileContents = fs.readFileSync config, { encoding: 'utf8' }
		JSON.parse fileContents

module.exports = Config