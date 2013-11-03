
require.config
	paths:
		lodash: '../node_modules/lodash/lodash'
		marked: '../node_modules/marked/lib/marked'

define (require) ->

	_ = require 'lodash'

	class Resume

		options:

			# how to contact you (supports `email`, `github`, `npm`, and `www`)
			contact: {}

			# element in which to render the resume
			element: document.body

			# work history
			history: {}

			# name
			name: 'John Smith'

			# HTML templates
			templateHeader: ->

				_labels =
					email: 'Email'
					github: 'Github'
					npm: 'NPM'
					www: 'Web'

				_template = (type, value) ->
					switch type
						when 'email' then "mailto:#{value}"
						when 'github' then "https://github.com/#{value}"
						when 'npm' then "https://npmjs.org/~#{value}"
						when 'www'
							if value.indexOf('http') isnt 0
							then "http://#{value}"
							else value

				contacts = ''

				for key, value of @contact
					contacts += """
						<li><a class="#{key}" href="#{_template key, value}">#{_labels[key]}</a></li>
					"""

				"""
					<header>
						<h1>#{@name}'s resume</h1>
						<ul>#{contacts}</ul>
					</header>
				"""

		history: ->

				history = @options.history

				# compute sizes
				height = 150
				size = @options.element.getBoundingClientRect()

				# render raphael container
				paper = Raphael 0, height, size.width, size.height - height

				# get timespan for each job
				for item in history

					# eg. time=['2012-06', '2013-06']
					time = item.when

					if time?

						time[0] = new Date (time[0] + '-01T12:00:00')
						time[1] = new Date (time[1] + '-01T12:00:00')

						diff = Math.abs(time[1].getTime() - time[0].getTime())
						days = Math.ceil(diff / (1000 * 3600 * 24))

						item.timespan = days

				# get largest timespan
				spans = _.pluck history, 'timespan'
				max = _.max spans

				#
				#
				# compute positions, making items with the largest timespans largest, like so:
				#  
				#   __
				#  /  \
				#  \__/   ____ 
				#        /    \     _______
				#       |      |   /       \       
				#        \____/   /         \
				#                |           |
				#                 \         /
				#                  \_______/     __
				#                               /  \
				#                               \__/
				#                               
				#               time ->
				# 
				#

				# convert to % of screen width
				n = 0
				accumulator = 0

				_.each history, (item) =>

					r = (size.width*item.timespan/max)/(2*Math.PI)
					x = accumulator + r
					y = 1.5*r

					item.timespan = x

					console.log x, y, r, size

					circle = paper.circle x, y, r

					circle
					.attr
						fill: 'rgba(26, 49, 97, 0.4)'
						stroke: 0
					.mouseover => @over circle
					.mouseout => @out circle
					.click => @click circle

					++n
					accumulator += 2*r
					
		constructor: (options) ->

			# set options
			_.extend @options, options

			# render it!
			@render()

		render: ->

			html = ''

			html += @options.templateHeader @options

			@options.element.innerHTML = html
			@history()

		click: (element) ->

			console.log element

			element.attr
				fill: 'rgba(26, 49, 97, 0.84)'

		over: (element) ->

			console.log 'hover'

			element.attr
				fill: 'rgba(26, 49, 97, 0.6)'

		out: (element) ->

			element.attr
				fill: 'rgba(26, 49, 97, 0.4)'

		setElement: (element) ->

			if element then @options.element = element

		setHistory: (history) ->

			if history then @options.history = history

