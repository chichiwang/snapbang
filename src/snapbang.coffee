# === Global Dependencies ===
fs = require 'fs'
_ = require 'lodash-node'
colors = require 'cli-color'
sm = require 'sitemap'

# === Color Definitions ===
notice = colors.bgCyanBright.black
debug = colors.bgYellowBright.black

# === Primary Execution Block ===
main = ->
	sitemap = createSitemap()
	console.log notice('INITIAL SITEMAP'), '\n', sitemap
	prepOptions()

# === Options Preparation ===
Config = {}
prepOptions = ->
	console.log notice('Prepare Options'), '\n', getArguments()

getArguments = ->
	args = _.cloneDeep process.argv
	args.splice 0,2
	args

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