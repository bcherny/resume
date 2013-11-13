spins off a Resume instance
===========================

	define (require) ->

		_ = require 'lodash'
		Resume = require 'resume'
		uxhr = require 'uxhr'

		div = document.getElementById 'resume'

get the current date and month as a string (eg. "2013-11")
	
		date = new Date()
		today = "#{date.getFullYear()}-#{date.getMonth()}"

load data

		uxhr 'data/data.json', {},
			complete: (res) ->
				init JSON.parse res



create a `Resume` instance!

		init = (data) ->

			data = _.extend data,
				element: div

			resume = new Resume data