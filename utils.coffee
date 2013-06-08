promise = require 'node-promise'

exports.promises = (f) ->
	(args...) ->
		d = promise.defer()
		
		f(d).apply this, args
		
		d.promise
		
exports.filtered = (filter, f) ->
	(from, to, text, message) ->
		args = from: from, to: to, text: text, message: message
		console.log args
		for k, v of filter
			console.log k, v
			if match = v.exec args[k]
				return f from, to, text, message, match