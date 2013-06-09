{ promises } = require '../../utils'

http = require 'http'
storage = require '../storage'
quote = require '../quote'
{ inspect } = require 'util'

app = null
server = null

exports.unload = ->
	server.close()
		
exports.init = promises (promise) -> ->
	express = require 'express'
	
	app = express()
#	app.use express.bodyParser()
	app.use express.static(__dirname + '/public')
	app.set 'view engine', 'jade'
	app.set 'views', __dirname + '/views'
	app.engine 'jade', require('jade').__express

	app.get '/', (req, res) ->
		console.log quote
		quote.Quote.findAll(order: 'created_at desc', limit: 50).success (quotes) ->
			res.render 'quotes', quotes: quotes, title: 'latest quotes'
	
	server = http.createServer(app)
	server.listen 4000
	
	promise.resolve()