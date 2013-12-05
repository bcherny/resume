module.exports = (grunt) ->

	grunt.initConfig

		pkg: grunt.file.readJSON 'package.json'
		
		requirejs:
			js:
				options:
					findNestedDependencies: true
					baseUrl: 'js'
					wrap: true
					preserveLicenseComments: false
					optimize: 'none'
					mainConfigFile: 'js/main.js'
					exclude: ['lodash']
					include: ['main.js']
					out: 'resume.js'
					onBuildWrite: (name, path, contents) ->
						(require 'amdclean').clean contents

	grunt.loadNpmTasks 'grunt-contrib-requirejs'
	grunt.registerTask 'build', ['requirejs:js']
	grunt.registerTask 'default', ['build']