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
	link = /<a href="./([^"]+)">[^<]+<\/a>/g;
	arr = null
	list = []
	while (match = link.exec(body))
		list.push 'http://www.phrenzy.org/temp/' + match[1]

	return

phrenzy = filtered text: /^\.random$/,
	(from, to, text, message) ->
		if list
			client.say to, list[Math.floor Math.random() * list.length]
		else
			http.get host: 'phrenzy.org', port: 80, path: '/temp/random.php', (res) ->
				body = ''
				res.on 'data', (chunk) ->
					body += chunk
				res.on 'end', ->
					update_list body
					client.say to, list[Math.floor Math.random() * list.length]


exports.unload = ->
	client.removeListener 'message', phrenzy

exports.init = promises (promise) -> (c) ->
	client = c

	client.on 'message', phrenzy

	promise.resolve()
