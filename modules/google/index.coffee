{ promises, filtered } = require('../../utils')
irc = require 'irc'
config = require '../../config'
google = require 'google'

client = null

bold = String.fromCharCode(0x02)
underline = String.fromCharCode(0x1F)

google_search = filtered text: /^\.google\s+(.*)\s*$/,
	(from, to, text, message, match) ->
		reply_to = (if to is config.botName then from else to)
		google match[1], (e, next, links) ->
			if e
				client.say reply_to, e
			else
				client.say reply_to, bold + links[0].title + bold + " - " + links[0].link
				client.say reply_to, links[0].description.substr(links[0].description.indexOf(s="Cached - Similar") + s.length)
				

exports.unload = ->
	client.removeListener 'message', google_search

exports.init = promises (promise) -> (c) ->
	client = c
		
	client.on 'message', google_search
	
	promise.resolve()