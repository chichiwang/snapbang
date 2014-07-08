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
	writeTempFile('test')

# === Options Preparation ===
Options =
	config: 'snapbang.json'
	tempDir: '.snapbang'
prepOptions = ->
	options = getOptions()
	console.log notice('Prepare Config'), '\n', options

getOptions = ->
	params = getParameters()
	options = false
	if _.isEmpty(params) and not fs.existsSync(Options.config)
		console.log errorTitle('Error:'), errorMsg('No config file found')
		throw new Error 'No config file found'
	else if params and fs.existsSync(params[0])
		options = getConfig params[0]
	else if fs.existsSync(Options.config)
		options = getConfig Options.config
	options
getParameters = ->
	args = _.cloneDeep process.argv
	args.splice 0,2
	args
getConfig = (config)->
	fileContents = fs.readFileSync config, { encoding: 'utf8' }
	JSON.parse fileContents

# === Temporary Files ===
writeTempFile = (str)->
	dir = Options.tempDir
	createDir dir

	# console.log notice('writeTempFile'), fs.existsSync(Options.tempDir)

# === Sitemap Functions ===
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

# === HELPER FUNCTIONS ===
escapeRegExp = (string) ->
	return string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")

createDir = (dir)->
	backSlash = new RegExp(escapeRegExp('\\'), 'g')
	dir = dir.replace backSlash, '/'
	dirs = dir.split('/')

	pathCreated = false

	currentDir = false
	for folder in dirs
		if currentDir is false
			currentDir = folder
		else
			currentDir = currentDir+slash+folder
		if not fs.existsSync(currentDir)
			fs.mkdirSync(currentDir)
			pathCreated = true
	pathCreated

exports.convert = main