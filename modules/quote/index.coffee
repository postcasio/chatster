storage = require '../storage'
Sequelize = require 'sequelize'
{ promises, filtered } = require('../../utils')

Quote = null

exports.init = promises (promise) -> (client) ->
	Quote = storage.db.define "Quote",
		quote: Sequelize.STRING,
		created_at: { type: Sequelize.DATE, defaultValue: Sequelize.NOW }
		created_by: Sequelize.STRING
		
	Quote.sync()
	
	client.addListener 'message', filtered text: /^\.quote$/, (from, to, text, message) ->
		_ = Quote.find(order: 'RANDOM()', limit: 1).success (quote) ->
			if quote is null
				client.say to, 'No quotes.'
			else
				client.say to, "#" + quote.id + " " + quote.quote
				
	client.addListener 'message', filtered text: /^\.quote\s+add\s+(.*)\s*$/,
		(from, to, text, message, match) ->
			Quote.create(quote: match[1], created_by: from).success (quote) ->
				client.say to, "Added quote #" + quote.id
	
	client.addListener 'message', filtered text: /^\.quote\s+search\s+(.*)\s*$/,
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
	
	client.addListener 'message', filtered text: /^.quote\s+help\s*$/,
		(from, to, text, message, match) ->
			client.say to, '.quote .......... random quote'
			client.say to, '.quote add ...... add a quote'
			client.say to, '.quote search ... search for a quote'
			
	promise.resolve()