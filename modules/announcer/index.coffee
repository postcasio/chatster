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
			when 4
				'ultra lol'
			when 5
				'm-m-m-monster lol'
			else
				null

		if timeout
			clearTimeout timeout

		if text
			setTimeout(->
				client.say to, text.toUpperCase() + "!!"
			, 2000)


exports.unload = ->
	client.removeListener 'message', lol

exports.init = promises (promise) -> (c) ->
	client = c

	client.on 'message', lol

	promise.resolve()
