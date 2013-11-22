throbber
========
	
	define (require) ->
		
		util = require 'util'

creates a throbbing bubble as an affordance indicating that it's clickable

		class Throbber

			options:
				duration: 500
				easing: 'linear'
				size: 10
				text: 'click me!'

			constructor: (@bubble, @graph) ->

				@state = true
				@r = @bubble.attr 'r'
				@x = @bubble.attr 'cx'
				@y = @bubble.attr 'cy'

				do @throb
				do @showMessage

			throb: =>

				@state = not @state

				@bubble.animate
					r: @r + (if @state then @options.size else 0)
				, @options.duration
				, @options.easing
				, @throb

			clear: =>

				do @bubble.stop

				util.classList.add @text, 'fade-out'

				setTimeout =>
					document.body.removeChild @text
				, 2000

			showMessage: ->

render the text

				element = @text = document.createElement 'div'
				element.id = 'clickme'
				element.innerHTML = @options.text
				element.style.cssText = "left:#{ @x - @r }px; top:#{ @y }px"

				document.body.appendChild element

set the left margin so the text is centered

				element.style.marginLeft = "#{ @r - element.offsetWidth / 2 }px"

then fade the text in

				util.classList.add element, 'fade-in'

then attach DOM events

				do @attachMessageEvents

			attachMessageEvents: ->

				@text.addEventListener 'mouseover', =>
					@graph.over @bubble

				@text.addEventListener 'mouseout', =>
					@graph.out @bubble

				@text.addEventListener 'click', =>
					@graph.click @bubble