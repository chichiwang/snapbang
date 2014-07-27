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
 * Copyright (c) 2014, Chi Wang
 * Licensed under the MIT license.
 */`

# [dep] Modules
fs = require 'fs'
colors = require './colors'

# [dep] Vendors
_ = require 'lodash-node'
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
		sm = require 'sitemap'
		smOptions = _processOptions url, routes
		sitemap = sm.createSitemap(smOptions)
		_formatSitemap sitemap.toString()

	_processOptions = (url, routes)->
		_validateParams url, routes

		urls = []
		for route in routes
			urls.push {
				url: route.route if defined(route.route)
				changefreq: route.changefreq if defined(route.changefreq)
				priority: route.priority if defined(route.priority)
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
	_validateParams = (url, routes)->
		# url must be a URL string
		isAddress = url.indexOf('http') is 0
		if not _.isString(url) or not isAddress
			err = "Sitemap: url passed into get() method must be a URL string"
			console.log err.error
			throw new Error err
		true

# [class] Snapshot Generator
class Snapbang
	_options = undefined
	constructor: (options)->
		@init options
	init: (options)->
		_options = _formatOptions options
		console.log 'SnapBang init:'.debug, _options
	_formatOptions = (options)->
		# snapshots defaults
		defaults =
			input: 'sitemap'
			outputDirClean: true
			selector: 'body'
			processLimit: 1
		
		# mandatory config
		sCfg = options.snapshots
		ssOpts =
			source: options.procDir+'/'+options.sitemap.filename
			hostname: ifDefinedElse(sCfg.url, options.url)
			outputDir: thisDir(sCfg.destination)
		# optional config
		ssOpts.outputPath = sCfg.outputPath if defined(sCfg.outputPath)
		ssOpts.auth = sCfg.auth if defined(sCfg.auth)
		ssOpts.selector = sCfg.selector if defined(sCfg.selector)
		ssOpts.processLimit = sCfg.processLimit if defined(sCfg.processLimit)

		_.merge ssOpts, defaults

	run: (options)->
		init(options) if options
		generate(_options)
	generate: (options)->
		# SNAPBANG

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
# ..
thisDir = (dir)->
	if not _.isString(dir)
		err = "[helper] thisDir: argument dir must be a string"
		console.log err.error
		throw new Error err
	isAbsolutePath = dir.charAt(0) is '/' or !!dir.match(/^.\//)
	if not isAbsolutePath
		'./'+dir
	else
		dir
# .. returns arg1 if it is defined - returns arg2 otherwise
ifDefinedElse = (v, w)->
	if defined(v) then v else w
# .. not _.isUndefined takes too long to write and reason about
defined = (v)->
		not _.isUndefined v
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
# .. rmDir
rmDir = (dir)->
	dirContents = fs.readdirSync dir
	if _.isEmpty(dirContents)
		fs.rmdirSync dir
		true
	else
		err = "rmDir: Directory not empty"
		console.log err.error
		throw new Error err

# .. validate config object for this app
_validateConfig = (configObj)->
	hasErr = false

	# check for sitemap and snapshots options
	sitemap = configObj.get('sitemap')
	if _.isUndefined(sitemap)
		configObj.set('sitemap', { enable: false })
	snapshots = configObj.get('snapshots')
	if _.isUndefined(snapshots)
		configObj.set('snapshots', { enable: false })
	if !configObj.get('sitemap.enabled') and !configObj.get('snapshots.enabled')
		err = "Config: Sitemap and Snapshots functionality both disabled"
		hasErr = false

	# check for base URL
	baseURL = configObj.get('url')
	if _.isUndefined(baseURL)
		err = "Config: Must declare a url"
		hassErr = true
	# check for routes
	routes = configObj.get('routes')
	if _.isUndefined(routes)
		err = "Config: Must have routes defined"
		hasErr = true
	if _.isObject(routes) and !_.isArray(routes)
		routes = [routes]
		configObj.set('routes', routes)
	hasRoutes = true
	(hasRoutes = (_.isString(route.route) and hasRoutes)) for route in routes
	if hasRoutes is false
		err = "Config: route param in each routes object must be defined"
		hasErr = true

	# throw errors
	if hasErr is true
		console.log err.error
		throw new Error err
	true



# [main]
sitemap = new Sitemap
snapmapDir = undefined
main = ->
	thisDir("./test")
	_validateConfig config

	if config.get('snapshots.enabled') is true
		# generate temporary sitemap for snapshots
		snapmapDir = createDir config.get('procDir')
		snapshotsURL = if config.get('snapshots.url') then config.get('snapshots.url') else config.get('url')
		snapmap = sitemap.get snapshotsURL, config.get('routes')
		filepath = snapmapDir+'/'+config.get('sitemap.filename')
		fs.writeFileSync filepath, snapmap

		# generate snapshots
		snapbang = new Snapbang config.get()

		disposeTempSitemap()
		# if config.get('sitemap.enabled') is true
		# 	generateSitemap()

		console.log 'main:'.notice, config.get()
disposeTempSitemap = ->
	# clean up temporary sitemap for snapshots
	filepath = snapmapDir+'/'+config.get('sitemap.filename')
	fs.unlinkSync filepath
	rmDir snapmapDir

generateSitemap = ->
	# build sitemap into destination directory
	sDir = createDir config.get('sitemap.destination')
	sitemapContents = sitemap.get config.get('url'), config.get('routes')
	filepath = sDir+'/'+config.get('sitemap.filename')
	fs.writeFileSync filepath, sitemapContents

exports.convert = main