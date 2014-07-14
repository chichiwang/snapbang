`/*
 * snapbang.js
 * 0.0.0
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

# [dep] Modules
fs = require 'fs'
colors = require './colors'

# [dep] Vendors
_ = require 'lodash-node'
sm = require 'sitemap'
snapshots = require 'html-snapshots'

# [class] Retrieve Config JSON
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

# [class] Sitemap Generator
class Sitemap
	get: (url, routes)->
		smOptions = _processOptions url, routes
		sitemap = sm.createSitemap(smOptions)
		_formatSitemap sitemap.toString()

	_processOptions = (url, routes)->
		_validateParams url, routes

		urls = []
		for route in routes
			urls.push {
				url: route.route if _isDefined(route.route)
				changefreq: route.changefreq if _isDefined(route.changefreq)
				priority: route.priority if _isDefined(route.priority)
			}

		options =
			hostname: url
			cacheTime: 0
			urls: urls
	_formatSitemap = (sitemapStr)->
		openUrl = new RegExp(escapeRegExp('<url>'), 'g')
		closeUrl = new RegExp(escapeRegExp(' </url>'), 'g')
		tagSpace =  new RegExp(escapeRegExp('> <'), 'g')
		sitemapStr.replace(openUrl, '	<url>').replace(closeUrl, '\n	</url>').replace(tagSpace,'>\n		<')
	_isDefined = (v)->
		not _.isUndefined v
	_validateParams = (url, routes)->
		# url must be a URL string
		isAddress = url.indexOf('http') is 0
		if not _.isString(url) or not isAddress
			err = "Sitemap: url passed into get() method must be a URL string"
			console.log err.error
			throw new Error err
		# routes be an array of options - option route must be defined
		isArray = _.isArray routes
		hasRoutes = true
		(hasRoutes = (_.isString(route.route) and hasRoutes)) for route in routes
		if hasRoutes is false
			err = "Sitemap: routes option in routes object must be defined"
			console.log err.error
			throw new Error err

# [control] Process Files
writeProcFile = ()->
	dir = createDir Options.procDir
	filepath = dir+'/'+Options.sitemap.filename

	url = Options.snapshots.url
	routes = Options.routes
	Options.sitemap.xml = sitemap.get(url, routes)

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

# [helpers]
# .. sanitize a string to make it safe for regexp
escapeRegExp = (string) ->
	return string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")
# .. deep mkdir
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
		fs.mkdirSync(currentDir) if not fs.existsSync(currentDir)
	currentDir

# [main]
sitemap = new Sitemap
main = ->
	console.log 'main:'.notice, config.get()

	if config.get('snapshots.enabled') is true
		snapmapDir = config.get 'procDir'
		snapmap = sitemap.get config.get('snapshots.url'), config.get('routes')
		console.log 'snapshots enabled'.debug, snapmapDir

exports.convert = main