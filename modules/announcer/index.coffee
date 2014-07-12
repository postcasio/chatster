storage = require '../storage'
{ promises, filtered } = require('../../utils')
irc = require 'irc'

client = null

bold = String.fromCharCode(0x02)
underline = String.fromCharCode(0x1F)

lols = 0

lol = (from, to, text, message) ->
	if text != 'lol'
		lols = 0
	else
		lols++

		text = switch lols
			when 2
				'double lol'
			when 3
				'triple lol'
			when 4
				'ultra lol'
			when 5
				'm-m-m-monster lol'

		if timeout
			clearTimeout timeout

		setTimeout(->
			client.say to, str.toUpperCase() + "!!"
		, 2000)


exports.unload = ->
	client.removeListener 'message', lol

exports.init = promises (promise) -> (c) ->
	client = c

	client.on 'message', lol

	promise.resolve()
