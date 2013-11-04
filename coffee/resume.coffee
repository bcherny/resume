
require.config
	paths:
		lodash: '../node_modules/lodash/lodash'
		marked: '../node_modules/marked/lib/marked'

define (require) ->

	_ = require 'lodash'

	months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
	strtotime = (string) ->
		new Date string + '-01T12:00:00'

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

			templateHistory: ->

				"""
					<div id="details">
						#{@content}
					</div>
				"""

			templateHistoryItem: ->

				# format dates
				from = strtotime @when[0]
				to = strtotime @when[1]
				from = "#{months[from.getMonth()]} #{from.getFullYear()}"
				to = "#{months[to.getMonth()]} #{to.getFullYear()}"

				# format skills
				skills = ''
				for skill in @skills
					skills += '<span class="tag">' + skill + '</span>'

				# title
				title = if @title then "<h3>#{@title}</h3>" else ''

				"""
					<section class="detail">
						#{title}
						<h2>#{@company}</h2>

						<span class="date">#{from} - #{to}</span>

						<dl>

							#{ if skills.length then '<dt>Skills</dt><dd>'+skills+'</dd>' }

						</dl>
					</section>
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

						time[0] = strtotime time[0]
						time[1] = strtotime time[1]

						diff = Math.abs(time[1].getTime() - time[0].getTime())
						days = Math.ceil(diff / (1000 * 3600 * 24))

						item.timespan = days

				# get largest timespan
				spans = _.pluck history, 'timespan'
				max = _.max spans

				#
				#
				# compute positions, making items with the largest timespans largest in size, like so:
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

				_.each history, (item, key) =>

					r = size.width*item.timespan/(max*2*Math.PI)
					x = accumulator + r
					y = r + 5 # .active stroke-width = 5px

					item.timespan = x

					circle = paper.circle x, y, r

					circle
					.mouseover => @over circle
					.mouseout => @out circle
					.click => @click circle

					circle.node.setAttribute 'class', "color#{n%5}"
					circle.node.setAttribute 'data-id', key

					++n
					accumulator += 2*r
					
		constructor: (options) ->

			# set options
			_.extend @options, options

			# render it!
			@render()

		render: ->

			html = ''
			htmlDetails = ''

			html += @options.templateHeader.call @options

			for item in @options.history
				htmlDetails += @options.templateHistoryItem.call item

			html += @options.templateHistory.call
				content: htmlDetails

			@options.element.innerHTML = html
			@history()

		click: (element) ->

			id = element.node.getAttribute 'data-id'

			# deactivate others?
			active = document.querySelector('circle.active')
			if active
				active.classList.remove 'active'

			# activate this
			element.node.classList.add 'active'

			# deactivate other details?
			active = document.querySelector('.detail.active')
			if active
				active.classList.remove 'active'

			# activate this detail panel
			document.querySelectorAll('.detail')[id].classList.add 'active'

		over: (element) ->

		out: (element) ->

		setElement: (element) ->

			if element then @options.element = element

		setHistory: (history) ->

			if history then @options.history = history

