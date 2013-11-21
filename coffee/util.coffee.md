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

					element.className += className

				remove: (element, className) ->

					regex = new RegExp "(^|\\s)#{className}(?:\\s|$)"
					element.className = (element.className + '').replace regex, '$1'

				contains: (element, className) ->

					(element.className.indexOf className) > -1