resume
======

	class Resume

		options:

			template: ->

				"""
				"""

		constructor: (element = document.body, data, options) ->

set options

			_.extend @options, options

set element?

			@setElement element if element

set data?

			@setData data if data

		setData: (@data) ->

			

		setElement: (@element) ->

