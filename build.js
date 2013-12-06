({
	baseUrl: 'js',
	findNestedDependencies: true,
	mainConfigFile: 'js/config.js',
	include: ['app.js'],
	optimize: 'none',
	// onBuildWrite: function (name, path, contents) {
	// 	module.require('amdclean').clean(contents);
	// },
	out: 'resume.js',
	preserveLicenseComments: false,
	wrap: true,
})