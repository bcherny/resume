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