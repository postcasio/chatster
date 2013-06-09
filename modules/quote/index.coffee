storage = require '../storage'
Sequelize = require 'sequelize'
{ promises, filtered } = require('../../utils')
irc = require 'irc'
http = require '../http'

Quote = null
client = null

random_quote = filtered text: /^\.quote$/,
	(from, to, text, message) ->
		Quote.find(order: 'RANDOM()', limit: 1).success (quote) ->
			if quote is null
				client.say to, 'No quotes.'
			else
				client.say to, "#" + quote.id + " " + quote.quote

add_quote = filtered text: /^\.quote\s+add\s+(.*)\s*$/,
	(from, to, text, message, match) ->
		Quote.create(quote: match[1], created_by: from).success (quote) ->
			client.say to, "Added quote #" + quote.id
			
search_quote = filtered text: /^\.quote\s+search\s+(.*)\s*$/,
	(from, to, text, message, match) ->
		Quote.find
			order: 'RANDOM()'
			where: ['quote LIKE ?', '%' + match[1] + '%']
			limit: 1
		.success (quote) ->
			if quote is null
				client.say to, 'No quotes found.'
			else
				client.say to, "#" + quote.id + " " + quote.quote
			
help = filtered text: /^.quote\s+help\s*$/,
	(from, to, text, message, match) ->
		client.say to, '.quote ' + irc.colors.wrap('gray', '..........') + ' random quote'
		client.say to, '.quote add ' + irc.colors.wrap('gray', '......') + ' add a quote'
		client.say to, '.quote search ' + irc.colors.wrap('gray', '...') + ' search for a quote'
		
exports.unload = ->
	client.removeListener 'message', random_quote
	client.removeListener 'message', add_quote
	client.removeListener 'message', search_quote
	client.removeListener 'message', help

exports.init = promises (promise) -> (c) ->
	client = c
	
	exports.Quote = Quote = storage.db.define "Quote",
		quote: Sequelize.STRING,
		created_at: { type: Sequelize.DATE, defaultValue: Sequelize.NOW }
		created_by: Sequelize.STRING
		
	Quote.sync()
	
	client.on 'message', random_quote
	client.on 'message', add_quote
	client.on 'message', search_quote
	client.on 'message', help
			
	promise.resolve()