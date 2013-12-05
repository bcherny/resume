## configure require paths

	require.config
		paths:
			annie: '../node_modules/annie/annie'
			GMaps: '../node_modules/gmaps/gmaps'
			#lodash: '../node_modules/lodash/lodash'
			marked: '../node_modules/marked/lib/marked'
			microbox: '../node_modules/microbox/microbox'
			strftime: '../node_modules/strftime/strftime'
			umodel: '../node_modules/umodel/umodel'
			uxhr: '../node_modules/uxhr/uxhr'
			u: '../node_modules/u/u'

		shim:
			strftime:
				exports: 'strftime'