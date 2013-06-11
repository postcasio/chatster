{ promises } = require '../../utils'

http = require 'http'
storage = require '../storage'
quote = require '../quote'
Sequelize = require 'sequelize'

{ inspect } = require 'util'

app = null
server = null
QuoteVote = null

exports.unload = ->
	server.close()
	delete require.cache[require.resolve './helpers']
		
setup_models = ->
	QuoteVote = storage.db.define 'QuoteVote',
		quote_id: Sequelize.INTEGER,
		ip: Sequelize.STRING(15),
		voted: Sequelize.INTEGER(1)
		
	QuoteVote.sync()
	
	quote.Quote.hasMany QuoteVote, foreignKey: 'quote_id'
		
exports.init = promises (promise) -> ->
	setup_models()

	express = require 'express'
	
	app = express()

	app.use express.static(__dirname + '/public')
	app.set 'view engine', 'jade'
	app.set 'views', __dirname + '/views'
	app.engine 'jade', require('jade').__express
	
	app.locals = require('./helpers')

	app.get '/', (req, res) ->
		quote.Quote.findAll(order: 'createdAt desc', limit: 50).success (quotes) ->
			res.render 'quotes', quotes: quotes, title: 'latest quotes'
			
	app.get /^\/vote\/(\d+)\/(up|down)/, (req, res) ->
		QuoteVote.findOrCreate({
			ip: req.ip, quote_id: req.params[0]
		}, {
			voted: (if req.params[1] == 'up' then 1 else -1)
		}).success (vote, created) ->
			return unless created
			
			quote.Quote.find(req.params[0]).success (quote) ->
				if req.params[1] == 'up'
					quote.votes_up++
				else
					quote.votes_down++
			
				quote.save().success ->
					res.send 'ok'
		
	
	server = http.createServer(app)
	server.listen 4000
	
	promise.resolve()