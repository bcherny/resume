module.exports = (grunt) ->

	glob = require 'glob'

	config =

		pkg: grunt.file.readJSON 'package.json'

		coffee:
			compile:
				files: {}
			options:
				bare: true

		concat:
			options:
				separator: ';'
			dist:
				src: ['node_modules/almond/almond.js', '<%= pkg.name %>.js']
				dest: '<%= pkg.name %>.js'
		
		# requirejs:
		# 	options:
		# 		findNestedDependencies: true
		# 		baseUrl: 'js'
		# 		wrap: true
		# 		preserveLicenseComments: false
		# 		optimize: 'none'
		# 		mainConfigFile: 'js/config.js'
		# 		include: ['app.js']
		# 		out: '<%= pkg.name %>.js'
				# onBuildWrite: (name, path, contents) ->
				# 	(require 'amdclean').clean contents
		
		shell:
			rjs:
				command: 'node ./node_modules/requirejs/bin/r.js -o build.js'
				options:
					stderr: true
					stdout: true

		uglify:
			options:
				mangle:
					toplevel: true
				compress:
					dead_code: true
					unused: true
					join_vars: true
				comments: false
				report: 'gzip'
			standard:
				files:
					'<%= pkg.name %>.min.js': '<%= pkg.name %>.js'

	# compile all coffeescripts into 'js/'
	for coffee in glob.sync 'coffee/*.coffee.md'
		name = (coffee.split '/')[1].slice 0,-10
		config.coffee.compile.files["js/#{name}.js"] = coffee

	# configure grunt
	grunt.config.init config

	# load tasks
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-requirejs'
	grunt.loadNpmTasks 'grunt-shell'

	# register tasks
	grunt.registerTask 'default', ['coffee', 'shell', 'concat', 'uglify']