{ promises, filtered } = require('../../utils')
irc = require 'irc'
{ exec } = require 'child_process'
config = require '../../config'
client = null

git_pull = filtered text: /^\.pull$/,
	(from, to, text, message) ->
		exec 'git pull origin master', (e, so, se) ->
			reply_to = (if to is config.botName then from else to)
			if se.length
				for line in se.trim().split("\n")
					client.say reply_to, line
			else
				line = so.trim().split("\n").pop()
				client.say reply_to, line

exports.unload = ->
	client.removeListener 'message', git_pull

exports.init = promises (promise) -> (c) ->
	client = c
		
	client.on 'message', git_pull
	
	promise.resolve()