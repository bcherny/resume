spins off a Resume instance
===========================

	div = document.getElementById 'resume'

get the current date and month as a string (eg. "2013-11")
	
	date = new Date()
	today = "#{date.getFullYear()}-#{date.getMonth()}"

define the data we'll be feeding into our `Resume` instance

	data =

		'BC Design':
			when: ['2002-01', today]
			url: 'bcdesignplace.com'
			description: 'My freelance web design company'
			responsibilities: """
				- Managing and acquiring clients, subcontracting and managing subcontractors and talent, design and development
				- Wireframing sites and applications in Photoshop, hand coding into HTML/CSS/JavaScript
				- Custom backends in PHP/MySQL, usually based on a framework like [Cake](http://cakephp.org/), [Symfony](http://symfony.com/), or [Zend](http://www.zend.com/en/)
				- UX design, usability testing, and A/B testing
				"""
			skills: ['HTML', 'CSS', 'JavaScript', 'PHP', 'MySQL', 'Photoshop', 'Illustrator']

		'C4':
			when: ['2009-09', '2011-10']
			description: 'Thin layer chromatography analysis software'
			responsibilities: """

				Creating a product website and administration backend for clients, as well as researching, developing, and implementing a fast and affordable alternative to existing medical densitometry software. My solution drove down the cost of high resolution thin layer chromatography imaging and densitometry software and hardware from $20,000 fixed cost for hardware plus $200 per test to $20 fixed and under $1 per test. I implemented the software using HTML, CSS, JavaScript, PHP (using the [GD](http://php.net/manual/en/book.image.php) and [ImageMagick](http://php.net/manual/en/book.imagick.php) imaging libraries), and MySQL.

				I also developed an automated web-based solution for printing test results in multiple formats, which helped drive down the cost of printing from over $2 per test to under $0.01 per test. The printing solution included a custom data-to-printable-HTML templating engine, CSS for layout, and Canvas (using [Raphael.js](http://raphaeljs.com/)) for charts.
			"""
			skills: ['HTML', 'CSS', 'JavaScript', 'PHP', 'MySQL', 'Photoshop', 'Illustrator', 'Stata', 'R', 'Print design']

		'ForwardMetrics':
			when: ['2011-11', '2012-06']
			url: 'forwardmetrics.com'
			title: 'Director of web development'
			description: 'Strategic planning software startup'
			responsibilities: """
				- Full design and implementation of a custom article publishing platform
				- Full design and implementation of strategic planning and performance review software
				- Creating a brand and corporate style
				- Managing off-site developers, setting scope and ensuring requirements are met
			"""
			skills: ['HTML', 'CSS', 'SASS', 'JavaScript', 'PHP', 'MySQL', 'Photoshop', 'Illustrator', 'FontCreator']

		'AgileMD':
			when: ['2012-06', '2013-06']
			url: 'agilemd.com'
			title: 'Senior front end developer'
			description: 'Clinical triage and decision making software for medical professionals'
			responsibilities: """
				- Rewriting the existing application frontend (including a custom directed graph renderer) from the ground up with focuses on performance and usability
				- Designing and implementing the frontend and middleware for a user-friendly authoring tool for use by doctors and 3rd and 4th years medical students
				- Ensuring that all products are performant across browsers (including IE7 and up, Chrome, Firefox, iOS, and Android)
				- Wireframing and developing numerous prototype spin-off products, some eventually making it to production
				- Leading usability improvement sprints involving user interviews, live and taped usability testing, automated A/B testing, competitor research, and adoption of concepts from other industries (eg. aviation checklists)
			"""
			skills: ['HTML', 'CSS', 'SASS', 'JavaScript', 'NodeJS', 'MongoDB', 'PHP', 'MySQL', 'Photoshop', 'Illustrator']

how to contact
		
	contact =
		email: 'boris@performancejs.com'
		github: 'eighttrackmind'
		npm: 'bcherny'
		www: 'performancejs.com'

create a `Resume` instance!

	resume = new Resume div, data