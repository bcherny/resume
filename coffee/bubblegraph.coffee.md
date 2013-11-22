bubblegraph resume component
============================

	define (require) ->

		_ = require 'lodash'
		umodel = require 'umodel'
		util = require 'util'

		class BubbleGraph

			options:

				colors: []
				data: {}
				element: document.body
				throbber:
					duration: 500
					easing: 'linear'
					size: 10
					text: 'click me!'

simple model to keep track of bubbles

			model: new umodel
				bubbles: {}

prepare `Raphael` animations

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

## constructor

			constructor: (options) ->

				_.extend @options, options

				do @render

## render

			render: ->

				data = @options.data

compute container size

				size = @options.element.getBoundingClientRect()
				height = size.height/3

render raphael container

				paper = Raphael @options.element, size.width, size.height

get timespan for each job

				for item in data

eg. `time = ['2012-06', '2013-06']`

					time = item.when

					if time?

						time[0] = util.strtotime time[0]
						time[1] = util.strtotime time[1]

						diff = Math.abs(time[1].getTime() - time[0].getTime())
						days = Math.ceil(diff / (1000 * 3600 * 24))

						item.timespan = days

get largest timespan, to scale bubbles appropriately

				spans = _.pluck data, 'timespan'
				max = _.max spans

compute positions with the following constraints:

- items with the largest time spans should be the largest in size
- very large bubbles should be scaled down, and very small ones scaled up
- bubbles should be tangent to one another
- the generated layout should be visually appealing

like so:

```text
      __
     /  \ ____ 
     \__//    \  _______
        |      |/       \       
         \____//         \
              |           |
               \         /
                \_______/__
                        /  \
                        \__/            
		time ->
```

				last = data.length - 1
				prev =
					r: null
					x: null
					y: null

loop over data items, generating bubbles along the way

				_.each data, (item, n) =>

					className = "color#{n%5}" # className for <circle>s
					r = size.width * item.timespan / (2 * max * Math.PI)

scale up small bubbles

					r += max/(5*r)
						
subsequent circles should form a "tail"

					if prev.x

y is derived using the distance formula,

```math
	d = √((x₂ - x₁)² + (y₂ - y₁)²)
```

substituting in the tangency condition for `d`,

```math
	d = r₁ + r₂
```

then solving for `x₂`:
							
						y = (size.height - height)/2 - .3*r + _.random 0,100
						x = prev.x + Math.sqrt(Math.abs((y - prev.y)*(y - prev.y) - (r + prev.r)*(r + prev.r)))

the first bubble should be at the bottom left, 5px from the bottom of the canvas

					else
						x = 20 + r
						y = size.height - r - 20

use `Raphael` to generate the bubble

					circle = paper.circle x, y, r
					circle.mouseover => @over circle
					circle.mouseout => @out circle
					circle.click => @click circle

colorize it. the last bubble (aka. the most recent project) should draw attention to itself, to encourage the user to click on it

					if n is last
						@throb circle, r
						@showClickMe x, y, r

					circle.node.setAttribute 'class', className
					circle.node.setAttribute 'data-id', n

use `Raphael` to style each bubble rather than CSS, because it behaves more consistently (even within modern browsers!!!)

					circle.attr
						opacity: .5
						stroke: '#fff'
						'stroke-width': 0

store in model

					@model.set "bubbles/#{n}",
						active: false
						raphael: circle

store parameters for the next iteration

					prev =
						circle: circle
						r: r
						x: x
						y: y

## throb
grow and shrink the last rendered bubble (aka. most recent project) as an affordance to the user that bubbles are clickable

			throb: (bubble, r, state = 0) =>

				bubble.animate
					r: r + (if state then @options.throbber.size else 0)
				, @options.throbber.duration
				, @options.throbber.easing
				, => @throb bubble, r, not state

## showClickMe
show "click me" message in the throbbing circle, also as an affordance that it is clickable

			showClickMe: (x, y, r) ->

				element = document.createElement 'div'
				element.id = 'clickme'
				element.innerHTML = @options.throbber.text
				element.style.cssText = "left:#{ x - r }px;top:#{ y }px"

				document.body.appendChild element

				# set the left margin so the text is centered
				element.style.marginLeft = "#{ r - element.offsetWidth / 2 }px"

				util.classList.add element, 'fade-in'

## clearThrobber

			clearThrobber: ->

				element = document.querySelector '.throb'

				if element
					util.classList.remove element, 'throb'

## deactivate
deactivates active circles, panes

			deactivate: ->

				pane = document.querySelector '.detail.active'
				active = _.where (@model.get 'bubbles'),
					active: true

				if active[0]

					bubble = active[0].raphael

					setTimeout =>
						
						util.classList.remove bubble.node, active

animate

						bubble
						.animate(@animations.inactive)
						.transform('s1')

					,10

update model

					active[0].active = false

hide pane

				if pane

					util.classList.remove pane, 'active'

					setTimeout ->
						util.classList.add pane, 'hide'
					, .2

hide details container

					util.classList.add (document.querySelector '#details'), 'hide'


scale up `<svg>`

					(document.querySelector 'svg').setAttribute 'class', ''

## activate
activates active circles, panes

			activate: (bubble) ->

				id = bubble.node.getAttribute 'data-id'

activate this

				util.classList.add bubble.node, 'active'

show details container

				util.classList.remove (document.querySelector '#details'), 'hide'

activate this detail panel

				panel = (document.querySelectorAll '.detail')[id]
				util.classList.remove panel, 'hide'
				util.classList.add panel, 'active'

animate

				bubble
				.toFront()
				.animate(@animations.active)
				.transform('s1.1')

scale down `<svg>`

				(document.querySelector 'svg').setAttribute 'class', 'small'

activate in model

				@model.set "bubbles/#{id}/active", true

## toggle

			toggle: (bubble) ->

				active = _.where (@model.get 'bubbles'),
					active: true

				do @deactivate

				if not active[0] or active[0].raphael isnt bubble
					@activate bubble

## click
`click` handler for bubbles

			click: (element) ->

clear throbbing circle (used as teaching tool)

				do @clearThrobber

activate this?

				@toggle element

## over
`mouseover` handler for bubbles

			over: (element) ->

				active = @model.get 'active'

				if element isnt active
					element.animate @animations.over

## out
`mouseout` handler for bubbles

			out: (element) ->

				active = @model.get 'active'

				if element isnt active
					element.animate @animations.out
