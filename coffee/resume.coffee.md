	define (require) ->

dependencies

		_ = require 'lodash'
		BubbleGraph = require 'bubblegraph'
		GMaps = require 'GMaps'
		marked = require 'marked'
		repocount = require 'repocount'
		strftime = require 'strftime'
		umodel = require 'umodel'
		util = require 'util'
		uxhr = require 'uxhr'

resume
======

		class Resume

## options

			options:

{String} your name

				name: 'John Smith'


{Object} how to contact you (supports `email`, `github`, `npm`, and `www`)

				contact: {}


{Element} where to render the resume

				element: document.body


{Array} work history

				history: []


{String} resume objective

				objective: ''


{Array} your skills

				skills: []


{Array} colors for bubbles

				colors: ['0B486B', 'A8DBA8', '79BD9A', '3B8686', 'CFF09E']


{Function} template for the header element

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


{Function} template for the cover (objective and skills)

				templateCover: ->

					skills = '<span class="tag">' + @skills.join('</span><span class="tag">') + '</span>'

					"""
						<div id="cover">
							<h3 id="objective">#{marked @objective}</h3>
							<div id="skills">#{skills}</div>
						</div>
					"""


{Function} template for work history (right sidebar)

				templateHistory: ->

					"""
						<div id="details" class="hide">
							#{@content}
						</div>
					"""


{Function} template for each work history item

				templateHistoryItem: ->

format dates

					from = strftime '%B %Y', util.strtotime @when[0]
					to = strftime '%B %Y', util.strtotime @when[1]

format location

					if @location
						location = (if @location.city then "#{@location.city}," else '') + ' ' + (@location.state or '')
					else
						location = ''

format skills

					skills = '<span class="tag">' + @skills.join('</span><span class="tag">') + '</span>'
					
explicitly define data (use an array rather than an object to maintain order)

					data = [
						{ field: 'company', value: "**#{@company}**" }
						{ field: 'title', value: @title }
						{ field: 'location', value: location }
						{ field: 'when', value: "#{from} - #{to}" }
						{ field: 'description', value: @description }
						{ field: 'responsibilities', value: @responsibilities }
						{ field: 'skills', value: skills }
					]

format other fields

					fields = ''
					for item in data
						fields += "<dt>#{item.field}</dt><dd>#{marked item.value}</dd>" if item.value?

google map

					map = if @location then """
						<span class="map-placeholder">
							Loading<br />
							map...
							<span class="spinner"></span>
						</span>
					""" else ''

return compiled

					"""
						<section class="detail hide">
							#{map}
							<dl>
								#{ fields }
							</dl>
						</section>
					"""

simple model

			model: new umodel
				graph: null

## constructor
						
			constructor: (options) ->

set options

				_.extend @options, options

attach DOM events

				@attachEvents()

render it!

				@render()

append CSS rules for properly sizing the bubbles when they're moved out of the way (aka. when they are clicked) to the stylesheet

				@resize()

## attachEvents

			attachEvents: ->

				document.addEventListener 'click', (e) => @clickBody e
				window.addEventListener 'resize', => @resize
				window.addEventListener 'deviceorientation', => @resize

## clickBody

			clickBody: (event) ->

				element = event.target
				isCircle = @isCircle element
				isDetails = @getDetails element
				graph = @model.get 'graph'

				if not isCircle and not isDetails and graph

					graph.deactivate()

scale up `<svg>`

					document.querySelector('svg').classList.remove 'small'

## isCircle

			isCircle: (element) ->

				element.tagName is 'circle'

## isDetails

			isDetails: (element) ->

				element.id is 'details'

## getDetails

			getDetails: (element) ->

				while element isnt document

					return element if @isDetails element

					element = element.parentNode

## render

			render: ->

				util.log 'rendering...'

				html = ''
				htmlDetails = ''

render header (title, contact information)

				html += @options.templateHeader.call @options

render objective, skills

				html += @options.templateCover.call @options

render history details (what shows up when user clicks on bubbles)

				for item in @options.history
					htmlDetails += @options.templateHistoryItem.call item

				html += @options.templateHistory.call
					content: htmlDetails

				@options.element.innerHTML = html

				util.log 'rendered history!'

render history bubbles

				@renderBubbles()
				util.log 'rendered bubbles!'

render maps

				@renderMaps()
				util.log 'rendered maps!'

fetch repo count?
				
				@getRepoCount()
				util.log 'fetched repos!'

## renderBubbles

			renderBubbles: ->

				graph = new BubbleGraph
					colors: @options.colors
					data: @options.history
					element: @options.element

				@model.set 'graph', graph

				
## renderMaps

			renderMaps: ->

compute details pane width

				details = document.querySelector '#details'

show the pane for a sec to give it a measurable `offsetWidth`

				details.classList.remove 'hide'
				width = details.offsetWidth - 20 # 20 is the padding
				details.classList.add 'hide'

				placeholders = details.querySelectorAll '.map-placeholder'

fetch map images from google using `GMaps`

				_.each @options.history, (item, n) =>

					location = item.location

					if location

						address = "#{location.address or ''} #{location.city or ''} #{location.state or ''}"
						src = GMaps.staticMapURL
							address: address
							markers: [
								{
									color: @options.colors[n%@options.colors.length]
									address: address
								}
							]
							size: [width, 150]
							zoom: 9

create an `<img>` for map

						img = document.createElement 'img'
						img.alt = ''
						img.className = 'map'
						img.src = src

wait for the image to finish loading, then render it nicely

						img.onload = ->

fade placeholder out

							placeholders[n].classList.add 'fade-out'

remove placeholder, inject map `<img>`

							setTimeout ->

remove, inject

								placeholders[n].parentNode.replaceChild img, placeholders[n]

force render before fading the map in

								_.defer ->
									img.classList.add 'fade-in'

							, 200

## getRepoCount
show a repository count in the DOM

			getRepoCount: ->

				if @options.contact.github
					new repocount
						github: @options.contact.github
					, (data) ->

						count = data.github.length
						elements = document.querySelectorAll '.github'

						for element in elements
							element.innerHTML += " (#{count})"

## resize
`window.resize` handler, also fired onLoad

			resize: ->

				scale = .7
				rotate = -60
				x = -28
				y = -27
				bin = Math.floor @options.element.offsetHeight/100

				if bin < 5

					scale = (bin+1)/10
					rotate = -60 + 20*(5 - bin)

define CSS rule for bubble group when it's activated and moved out of the way

				rule =
					"""
						svg.small {
							-webkit-transform: scale(#{scale}) translate3d(#{x}%, #{y}%, 0) rotate(#{rotate}deg);
							   -moz-transform: scale(#{scale}) translate3d(#{x}%, #{y}%, 0) rotate(#{rotate}deg);
							    -ms-transform: scale(#{scale}) translate3d(#{x}%, #{y}%, 0) rotate(#{rotate}deg);
							     -o-transform: scale(#{scale}) translate3d(#{x}%, #{y}%, 0) rotate(#{rotate}deg);
							        transform: scale(#{scale}) translate3d(#{x}%, #{y}%, 0) rotate(#{rotate}deg);
						}
					"""

Append to the DOM. See http://stackoverflow.com/a/707794/435124 for how CSS rule insertion works
			
				sheet = document.styleSheets[0]
				sheet.insertRule rule, sheet.cssRules.length