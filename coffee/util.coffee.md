resume.util
===========

	define (require) ->

		util =

## strtotime

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