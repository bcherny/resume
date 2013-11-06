
require.config
	paths:
		GMaps: '../../github/gmaps/gmaps'
		lodash: '../node_modules/lodash/lodash'
		marked: '../node_modules/marked/lib/marked'
		umodel: '../node_modules/umodel/umodel'

define (require) ->

	_ = require 'lodash'
	GMaps = require 'GMaps'
	marked = require 'marked'
	umodel = require 'umodel'

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

			templateCover: ->

				# collect skills
				# skills = []
				# _.each @history, (item) ->
				# 	if item.skills
				# 		skills = skills.concat item.skills
				# skills = _.unique skills

				skills = '<span class="tag">' + @skills.join('</span><span class="tag">') + '</span>'

				"""
					<div id="cover">
						<h3 id="objective">#{marked @objective}</h3>
						<div id="skills">#{skills}</div>
					</div>
				"""

			templateHistory: ->

				"""
					<div id="details" class="hide">
						#{@content}
					</div>
				"""

			templateHistoryItem: ->

				# format dates
				from = strtotime @when[0]
				to = strtotime @when[1]
				from = "#{months[from.getMonth()]} #{from.getFullYear()}"
				to = "#{months[to.getMonth()]} #{to.getFullYear()}"

				# format location
				if @location
					location = (if @location.city then "#{@location.city}," else '') + ' ' + (@location.state or '')
				else
					location = ''

				# format skills
				skills = '<span class="tag">' + @skills.join('</span><span class="tag">') + '</span>'
				
				# explicitly define data (using array instead of object to maintain order)
				data = [
					{ field: 'company', value: "**#{@company}**" }
					{ field: 'title', value: @title }
					{ field: 'location', value: location }
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
				map = if @location then """
					<span class="map-placeholder">
						Loading<br />
						map...
						<span class="spinner"></span>
					</span>
				""" else ''

				"""
					<section class="detail hide">
						#{map}
						<dl>
							#{ fields }
						</dl>
					</section>
				"""

		model: new umodel

			active: null

		animations:

			active: Raphael.animation
					opacity: 1
					'stroke-width': 5
				, 200

			inactive: Raphael.animation
					opacity: .5
					'stroke-width': 0
				, 200

			over: Raphael.animation
					opacity: .7
				, 200

			out: Raphael.animation
					opacity: .5
				, 200

		renderBubbles: ->

				history = @options.history

				# compute sizes
				size = @options.element.getBoundingClientRect()
				height = size.height/3

				# render raphael container
				paper = Raphael 0, 0, size.width, size.height

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
				#	compute positions with the following constraints:
				# 
				#	 - items with the largest time spans should be the largest in size
				#	 - very large bubbles should be scaled down, and very small ones scaled up
				#	 - bubbles should be tangent to one another
				#	 - the generated layout should be visually appealing
				#
				#     __
				#    /  \ ____ 
				#    \__//    \  _______
				#       |      |/       \       
				#        \____//         \
				#             |           |
				#              \         /
				#               \_______/__
				#                       /  \
				#                       \__/
				#                               
				#         time ->
				#

				last = history.length - 1
				prev =
					r: null
					x: null
					y: null

				_.each history, (item, n) =>

					r = size.width*item.timespan/(max*2*Math.PI)
					r += max/(5*r) # scale up small bubbles
					
					# subsequent circles should form a tail
					if prev.x

						#
						#	y is derived using the distance formula,
						#	
						#		d = √((x₂ - x₁)² + (y₂ - y₁)²)
						#		
						#	substituting in the tangency condition for d,
						#	
						#		d = r₁ + r₂
						#		
						#	then solving for x₂
						#
						
						y = (size.height - height)/2 - .3*r + _.random 0,100
						x = prev.x + Math.sqrt(Math.abs((y - prev.y)*(y - prev.y) - (r + prev.r)*(r + prev.r)))
						# y = _.random .8*size.height, 1.2*size.height

					# first circle should be at the bottom left, 5px from the bottom of the canvas
					else
						x = 20 + r
						y = size.height - r - 20

					circle = paper.circle x, y, r
					circle.mouseover => @over circle
					circle.mouseout => @out circle
					circle.click => @click circle

					className = "color#{n%5}"

					if n is last
						className += ' throb'

					circle.node.setAttribute 'class', className
					circle.node.setAttribute 'data-id', n

					circle.attr
						opacity: .5
						stroke: '#fff'
						'stroke-width': 0

					# store for the next iteration
					prev =
						r: r
						x: x
						y: y
					
		constructor: (options) ->

			# set options
			_.extend @options, options

			# attach DOM events
			@attachEvents()

			# render it!
			@render()

		attachEvents: ->

			document.addEventListener 'click', (e) => @clickBody e

		clickBody: (event) ->

			element = event.target
			isCircle = @isCircle element
			isDetails = @getDetails element

			if not isCircle and not isDetails

				@deactivate()

		isCircle: (element) ->

			element.tagName is 'circle'

		isDetails: (element) ->

			element.id is 'details'

		getDetails: (element) ->

			while element isnt document

				return element if @isDetails element

				element = element.parentNode

		render: ->

			html = ''
			htmlDetails = ''

			# render header (title, contact information)
			html += @options.templateHeader.call @options

			# render objective, skills
			html += @options.templateCover.call @options

			# render history details (what shows up when user clicks on bubbles)
			for item in @options.history
				htmlDetails += @options.templateHistoryItem.call item

			html += @options.templateHistory.call
				content: htmlDetails

			@options.element.innerHTML = html

			# render history bubbles
			@renderBubbles()

			# render maps
			@renderMaps()

		renderMaps: ->

			# compute details pane width
			details = document.querySelector '#details'

			details.classList.remove 'hide'
			width = details.offsetWidth - 20 # 20 is the padding
			details.classList.add 'hide'

			placeholders = details.querySelectorAll '.map-placeholder'
			circles = document.querySelectorAll 'circle'

			# fetch map images from google

			_.each @options.history, (item, n) ->

				location = item.location

				if location

					address = "#{location.address or ''} #{location.city or ''} #{location.state or ''}"
					src = GMaps.staticMapURL
						address: address
						markers: [
							{
								color: getComputedStyle(circles[n]).fill
								address: address
							}
						]
						size: [width, 150]
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

		clearThrobber: ->

			element = document.querySelector '.throb'

			if element
				element.classList.remove 'throb'

		deactivate: ->

			circle = document.querySelector 'circle.active'
			pane = document.querySelector '.detail.active'

			if circle
				circle.classList.remove 'active'

				element = @model.get 'active'

				# animate
				element.animate @animations.inactive
				element.transform 's1'

				# update model
				@model.set 'active', null

			if pane

				# hide pane
				pane.classList.remove 'active'

				setTimeout ->
					pane.classList.add 'hide'
				, .2

				# hide details container
				document.querySelector('#details').classList.add 'hide'

				# scale up <svg>
				document.querySelector('svg').classList.remove 'small'

		activate: (element) ->

			id = element.node.getAttribute 'data-id'

			# activate this
			element.node.classList.add 'active'

			# show details container
			document.querySelector('#details').classList.remove 'hide'

			# activate this detail panel
			classList = document.querySelectorAll('.detail')[id].classList

			classList.remove 'hide'
			classList.add 'active'

			# animate
			element
			.toFront()
			.animate(@animations.active)
			.transform('s1.1')

			# scale down <svg>
			document.querySelector('svg').classList.add 'small'

			# store in model
			@model.set 'active', element

		click: (element) ->

			# clear throbbing circle (used as teaching tool)
			@clearThrobber()

			# deactivate others?
			@deactivate()

			# activate this
			@activate element

		over: (element) ->

			active = @model.get 'active'

			if element isnt active
				element.animate @animations.over

		out: (element) ->

			active = @model.get 'active'

			if element isnt active
				element.animate @animations.out

		setElement: (element) ->

			if element then @options.element = element

		setHistory: (history) ->

			if history then @options.history = history

