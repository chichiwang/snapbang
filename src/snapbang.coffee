fs = require 'fs'
colors = require 'cli-color'
sm = require 'sitemap'

# Color definitions
notice = colors.bgCyanBright.black

main = ->
	sitemap = createSitemap()
	console.log notice('INITIAL SITEMAP'), sitemap

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