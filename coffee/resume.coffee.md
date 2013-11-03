resume
======

	class Resume

		options:

how to contact you (supports `email`, `github`, `npm`, and `www`)

			contact: {}

element in which to render the resume

			element: document.body

work history

			history: {}

name

			name: 'John Smith'

HTML templates

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
						when 'www' then value

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

		constructor: (options) ->

set options

			_.extend @options, options

render it!

			@render()


		render: ->

			html = ''

			html += @options.templateHeader @options

			@options.element.innerHTML = html


		setElement: (element) ->

			if element then @options.element = element

		setHistory: (history) ->

			if history then @options.history = history

