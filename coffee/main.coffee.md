## configure require paths

	require.config
		paths:
			annie: '../node_modules/annie/annie'
			GMaps: '../node_modules/gmaps/gmaps'
			lodash: '../node_modules/lodash/lodash'
			marked: '../node_modules/marked/lib/marked'
			microbox: '../node_modules/microbox/microbox'
			repocount: '../node_modules/repocount/repocount'
			snap: '../node_modules/Snap.svg/dist/snap.svg'
			strftime: '../node_modules/strftime/strftime'
			umodel: '../node_modules/umodel/umodel'
			uxhr: '../node_modules/uxhr/uxhr'
			u: '../node_modules/u/u'

		shim:
			strftime:
				exports: 'strftime'

## spin off a Resume instance

	define (require) ->

		_ = require 'lodash'
		Resume = require 'resume'
		uxhr = require 'uxhr'

initializes resume

		init = (data) ->

			new Resume _.extend data,
				element: document.getElementById 'resume'

loads data

		load = (url, callback) ->
			uxhr url, {},
				complete: (res) ->
					callback JSON.parse res

create a `Resume` instance!

		load 'data/data.json', init