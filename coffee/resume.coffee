
require.config
	paths:
		lodash: '../node_modules/lodash/lodash'
		marked: '../node_modules/marked/lib/marked'
		GMaps: '../../github/gmaps/gmaps'

define (require) ->

	_ = require 'lodash'
	GMaps = require 'GMaps'
	marked = require 'marked'

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
				
				# explicitly define data (using array instead of object to maintain order)
				data = [
					{ field: 'title', value: @title }
					{ field: 'company', value: @company }
					{ field: 'location', value: @location }
					{ field: 'when', value: "#{from} - #{to}" }
					{ field: 'description', value: @description }
					{ field: 'responsibilities', value: @responsibilities }
					{ field: 'skills', value: skills }
				]

				# format other fields
				fields = ''
				for item in data
					fields += "<dt>#{item.field}</dt><dd>#{marked item.value}</dd>" if item.value?

				# google map
				map = if @location then '<span class="spinner map-placeholder"></span>' else ''

				"""
					<section class="detail">
						#{map}
						<dl>
							#{ fields }
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

					circle.mouseover => @over circle
					circle.mouseout => @out circle
					circle.click => @click circle

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

			# render maps
			placeholders = document.querySelectorAll '#details .map-placeholder'
			circles = document.querySelectorAll 'circle'

			_.each @options.history, (item, n) ->

				if item.location
					GMaps.geocode
						address: item.location
						callback: (results, status) ->

							if status is 'OK'

								coords = results[0].geometry.location
								src = GMaps.staticMapURL
									lat: coords.lb
									lng: coords.mb
									markers: [
										{
											color: getComputedStyle(circles[n]).fill
											lat: coords.lb
											lng: coords.mb
										}
									]
									size: [338, 150]
									zoom: 9

								# create <img> for map
								img = document.createElement 'img'
								img.alt = ''
								img.className = 'map'
								img.src = src

								# wait for the image to finish loading
								img.onload = ->

									# fade placeholder out
									placeholders[n].classList.add 'fade-out'

									# remove placeholder, inject map <img>
									setTimeout ->

										# remove, inject
										placeholders[n].parentNode.replaceChild img, placeholders[n]

										# force render before fading the map in
										setTimeout ->
											img.classList.add 'fade-in'
										, 0

									, 200

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

