{ promises, filtered } = require('../../utils')
irc = require 'irc'
{ exec } = require 'child_process'

client = null

git_pull = filtered text: /^\.pull$/,
	(from, to, text, message) ->
		exec 'git pull', (e, so, se) ->
			t = so.trim() + "\n" + se.trim()
			for line in t.split "\n"
				client.say from, line

exports.unload = ->
	client.removeListener 'message', git_pull

exports.init = promises (promise) -> (c) ->
	client = c
		
	client.on 'message', git_pull
	
	promise.resolve()