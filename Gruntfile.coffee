module.exports = (grunt) ->

	glob = require 'glob'

	config =

		pkg: grunt.file.readJSON 'package.json'

		coffee:
			compile:
				files: {}
				
			options:
				bare: true
		
		requirejs:
			js:
				options:
					findNestedDependencies: true
					baseUrl: 'js'
					wrap: true
					preserveLicenseComments: false
					optimize: 'none'
					mainConfigFile: 'js/config.js'
					exclude: []
					include: ['app.js']
					out: 'resume.js'
					# onBuildWrite: (name, path, contents) ->
					# 	(require 'amdclean').clean contents
					# 	
		uglify:
			options:
				mangle:
					toplevel: true
				compress:
					dead_code: true
					unused: true
					join_vars: true
				comments: false
			standard:
				files: {}

	# compile all coffeescripts into 'js/'
	for coffee in glob.sync 'coffee/*.coffee.md'
		name = (coffee.split '/')[1].slice 0,-10
		config.coffee.compile.files["js/#{name}.js"] = coffee

	# configure grunt
	grunt.config.init config

	# load tasks
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-requirejs'

	# register tasks
	grunt.registerTask 'build', ['coffee', 'requirejs:js']
	grunt.registerTask 'default', ['build']