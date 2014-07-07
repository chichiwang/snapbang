# Global Dependencies
fs = require 'fs'
_ = require 'lodash-node'
colors = require 'cli-color'
sm = require 'sitemap'

# Global Variables
isWindows = process.platform is 'win32'
slash = if isWindows then '\\' else '/'

# === Color Definitions ===
notice = colors.bgCyanBright.black
debug = colors.bgYellowBright.black
errorTitle = colors.bgRedBright.black
errorMsg = colors.redBright.bgBlack

# === Primary Execution Block ===
main = ->
	# sitemap = createSitemap()
	# console.log notice('INITIAL SITEMAP'), '\n', sitemap
	prepOptions()

# === Options Preparation ===
Config =
	configFile: 'snapbang.json'
prepOptions = ->
	options = getOptions()

	console.log notice('Prepare Options'), '\n', options

getOptions = ->
	params = getParameters()
	options = false
	if _.isEmpty(params) and not fs.existsSync(Config.configFile)
		console.log errorTitle('Error:'), errorMsg('No config file found')
		throw new Error 'No config file found'
	else if params and fs.existsSync(params[0])
		options = getConfig params[0]
	else if fs.existsSync(Config.configFile)
		options = getConfig Config.configFile
	options
getParameters = ->
	args = _.cloneDeep process.argv
	args.splice 0,2
	args
getConfig = (configFile)->
	fileContents = fs.readFileSync configFile, { encoding: 'utf8' }
	JSON.parse fileContents

# === Sitemap Generation ===
createSitemap = ->
	sitemap = sm.createSitemap ({
			hostname: 'http://example.com',
			cacheTime: 0,
			urls: [
				{ url: '/#!/page-1/',  changefreq: 'daily', priority: 0.3 },
				{ url: '/#!/page-2/',  changefreq: 'monthly',  priority: 0.7 },
				{ url: '/#!/page-3/' }
			]
	})
	sitemap.toString()

exports.convert = main