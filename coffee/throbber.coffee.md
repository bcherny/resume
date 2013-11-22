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

			constructor: (@bubble) ->

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

			clear: ->

			showMessage: ->

render the text

				element = document.createElement 'div'
				element.id = 'clickme'
				element.innerHTML = @options.text
				element.style.cssText = "left:#{ @x - @r }px; top:#{ @y }px"

				document.body.appendChild element

set the left margin so the text is centered

				element.style.marginLeft = "#{ @r - element.offsetWidth / 2 }px"

then fade the text in

				util.classList.add element, 'fade-in'