# Vendors
_ = require 'lodash-node'
colors = require 'cli-color'

# Color Definitions
themes =
	notice : colors.bgCyanBright.black
	debug : colors.bgYellowBright.black
	error : colors.redBright.bgBlack

stringPrototypeBlacklist = [
    '__defineGetter__', '__defineSetter__', '__lookupGetter__', '__lookupSetter__', 'charAt', 'constructor',
    'hasOwnProperty', 'isPrototypeOf', 'propertyIsEnumerable', 'toLocaleString', 'toString', 'valueOf', 'charCodeAt',
    'indexOf', 'lastIndexof', 'length', 'localeCompare', 'match', 'replace', 'search', 'slice', 'split', 'substring',
    'toLocaleLowerCase', 'toLocaleUpperCase', 'toLowerCase', 'toUpperCase', 'trim', 'trimLeft', 'trimRight'
]

# Register themes to String.prototype
initialized = false
initialize = (options={})->
	themes = _.merge themes, options
	for theme of themes
		if theme in stringPrototypeBlacklist
			err = 'Colors: '+theme+' is a String property you do not want to overwrite!'
			console.log(colors.redBright.bgBlack(err))
			throw new Error err
		else
			addTheme theme, themes[theme]
	initialized = true

applyTheme = (func)->
	func(this)
addTheme = (theme, func)->
	String.prototype.__defineGetter__(theme, ()->
		applyTheme.apply(this, [func]);
	)

# Initialize the module
initialize() if not initialized
module.exports = initialized