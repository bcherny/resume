resume.util
===========

	define (require) ->

		util =

## strtotime
converts year-month strings like `2012-01` to timestamps

			strtotime: (string) ->
				new Date "#{string}-01T12:00:00"

## log
logging for load performance metrics

			log: (message) ->

				time = +new Date()

				if not @time
					@time = time

				console.log message, " (#{time - @time}ms)"

				@time = time

## classList
manipulate `Element.classList` in an Internet Explorer-compatible way

			classList:

				add: (element, className) ->

					if element.tagName is 'circle'
						element.setAttribute 'class', "#{className} #{element.className.baseVal}"

					else
						element.className += " #{className}"

				remove: (element, className) ->

					regex = new RegExp "(^|\\s)#{className}(?:\\s|$)"

					if element.tagName is 'circle'
						element.setAttribute 'class', (element.className.baseVal + '').replace regex, '$1'

					else
						element.className = (element.className + '').replace regex, '$1'

				contains: (element, className) ->

					value = element.className

					if element.tagName is 'circle'
						value = value.baseVal

					(value.indexOf className) > -1