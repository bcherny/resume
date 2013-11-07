
	define (require) ->

		_ = require 'lodash'

		class BubbleGraph

			options:

				data: {}
				element: document.body

			constructor: (options) ->

				_.extend @options, options

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

						time[0] = strtotime time[0]
						time[1] = strtotime time[1]

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
					r = size.width*item.timespan/(max*2*Math.PI)

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
						className += ' throb'

					circle.node.setAttribute 'class', className
					circle.node.setAttribute 'data-id', n

use `Raphael` to style each bubble rather than CSS, because it behaves more consistently (even within modern browsers!!!)

					circle.attr
						opacity: .5
						stroke: '#fff'
						'stroke-width': 0

store parameters for the next iteration

					prev =
						circle: circle
						r: r
						x: x
						y: y
