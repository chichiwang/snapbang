`/*
 * snapbang.js
 *
 * A utility which provides an automated process for
 * generating a sitemap.xml and static html snapshots
 * for the purposes of SEO and social network integration.
 *
 * This utility wraps the following packages:
 *    sitemap.js (https://github.com/ekalinin/sitemap.js)
 *    html-snapshots.js (https://github.com/localnerve/html-snapshots)
 * 
 * Ideal for client-side web applications.
 *
 * Copyright (c) 2014, Chi Wang, contributors
 * Licensed under the MIT license.
 */`

# Modules
fs = require 'fs'
colors = require './colors'

# Vendors
_ = require 'lodash-node'
sm = require 'sitemap'
snapshots = require 'html-snapshots'

# Retrieve Config JSON
Config = require './config'
config = new Config
	configFile: 'snapbang.json'
	defaults:
		procDir: '.snapbang'
		sitemap:
			enabled: false
			filename: 'sitemap.xml'
		snapshots:
			enabled: false

# Primary Execution Block
main = ->
	console.log 'options:'.notice, config.get('snapshots.auth')
	config.set('snapshots.auth', 'new:auth')
	console.log 'options:'.notice, config.get('snapshots.auth')
	# sitemap = createSitemap()
	# console.log notice('INITIAL SITEMAP'), '\n', sitemap
	# prepOptions()
	# writeProcFile()
	# createSnapshots()
	# dispose()

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