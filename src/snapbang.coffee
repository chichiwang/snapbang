`/*
 * snapbang.js
 *
 * A utility which provides an automated process for
 * generating a sitemap.xml and static html snapshots
 * for the purposes of SEO and social network integration.
 *
 * This utility wraps the following apps:
 *    sitemap.js (https://github.com/ekalinin/sitemap.js)
 *    html-snapshots.js (https://github.com/localnerve/html-snapshots)
 * 
 * Ideal for client-side web applications.
 *
 * Copyright (c) 2014, Chi Wang, contributors
 * Licensed under the MIT license.
 */`

# Vendors
fs = require 'fs'
_ = require 'lodash-node'
colors = require 'cli-color'
sm = require 'sitemap'
snapshots = require 'html-snapshots'

# 
Config = require './config'

# === Color Definitions ===
notice = colors.bgCyanBright.black
debug = colors.bgYellowBright.black
errorTitle = colors.bgRedBright.black
errorMsg = colors.redBright.bgBlack

# === Primary Execution Block ===
main = ->
	# sitemap = createSitemap()
	# console.log notice('INITIAL SITEMAP'), '\n', sitemap
	# prepOptions()
	# writeProcFile()
	# createSnapshots()
	# dispose()

# 
# === Options Preparation ===
Options =
	configFile: 'snapbang.json'
	procDir: '.snapbang'
	sitemap:
		filename: 'sitemap.xml'
prepOptions = ->
	options = getOptions()
	Options = _.merge Options, options 
	console.log notice('Prepare Config'), '\n', Options

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
getConfig = (config)->
	fileContents = fs.readFileSync config, { encoding: 'utf8' }
	JSON.parse fileContents

# === Process Files ===
writeProcFile = ->
	dir = createDir Options.procDir
	filepath = dir+'/'+Options.sitemap.filename

	url = Options.snapshots.url
	routes = Options.routes
	Options.sitemap.xml = getSitemap(sitemapOptions(url, routes))

	fs.writeFileSync filepath, Options.sitemap.xml

dispose = ->
	rmProcFile()
	rmProcDir()
rmProcDir = ->
	dirContents = fs.readdirSync Options.procDir
	if _.isEmpty(dirContents)
		fs.rmdirSync Options.procDir
		true
	else
		console.log errorTitle('Error:'), errorMsg('Temp Directory Not Empty')
		throw new Error 'Temp Directory Not Empty'
rmProcFile = ->
	filepath = Options.procDir+'/'+Options.sitemap.filename
	fs.unlinkSync filepath

# === Sitemap Functions ===
sitemapOptions = (url, routes)->
	urls = []
	for route in routes
		urls.push {
			url: route.route if not _.isUndefined(route.route)
			changefreq: route.changefreq if not _.isUndefined(route.changefreq)
			priority: route.priority if not _.isUndefined(route.priority)
		}

	options =
		hostname: url
		cacheTime: 0
		urls: urls
getSitemap = (options)->
	sitemap = sm.createSitemap(options)
	formatSitemap sitemap.toString()
formatSitemap = (sitemapStr)->
	openUrl = new RegExp(escapeRegExp('<url>'), 'g')
	closeUrl = new RegExp(escapeRegExp(' </url>'), 'g')
	tagSpace =  new RegExp(escapeRegExp('> <'), 'g')
	sitemapStr.replace(openUrl, '	<url>').replace(closeUrl, '\n	</url>').replace(tagSpace,'>\n		<')

# === Snapshot Functions ===
createSnapshots: ->
	# ...

snapshotTest = ->
	success = snapshots.run
		input: 'sitemap'
		source: Options.procDir+'/'+Options.sitemap.filename
		hostname: Options.snapshots.url
		outputDir: './dist'
		outputDirClean: true
		outputPath:
			"http://tlbprototype.art-sucks.com/#news": "./dist"
			"http://tlbprototype.art-sucks.com/#traditional": "./dist"
		auth: 'test:password'
		selector: 'body'
		processLimit: 1
# === HELPER FUNCTIONS ===
escapeRegExp = (string) ->
	return string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")

createDir = (dir)->
	backSlash = new RegExp(escapeRegExp('\\'), 'g')
	dir = dir.replace backSlash, '/'
	dirs = dir.split('/')
	currentDir = false

	for folder in dirs
		if currentDir is false
			currentDir = folder
		else
			currentDir = currentDir+'/'+folder
		if not fs.existsSync(currentDir)
			fs.mkdirSync(currentDir)
	currentDir

exports.convert = main