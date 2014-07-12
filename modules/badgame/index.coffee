storage = require '../storage'
{ promises, filtered } = require('../../utils')
irc = require 'irc'
http = require 'http'
client = null

bold = String.fromCharCode(0x02)
underline = String.fromCharCode(0x1F)

list = null
list_time = 0

update_list = (body) ->
	link = /<a href="([a-f0-9]\.png)">[a-f0-9]\.png<\/a>/g;
	arr = null
	list = []
	while (match = link.exec(body)) is not null
		list.push 'http://badgame.net/banners/' + match[1]
	return

badgame = filtered text: /^\.badgame$/,
	(from, to, text, message) ->
		if list
			client.say to, list[Math.floor Math.random() * list.length]
		else
			http.get host: 'badgame.net', port: 80, path: '/banners/', (res) ->
				body = ''
				res.on 'data', (chunk) ->
					body += chunk
				res.on 'end', ->
					update_list body
					client.say to, list[Math.floor Math.random() * list.length]


exports.unload = ->
	client.removeListener 'message', badgame

exports.init = promises (promise) -> (c) ->
	client = c

	client.on 'message', badgame

	promise.resolve()
