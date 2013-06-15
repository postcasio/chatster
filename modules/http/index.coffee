{ promises } = require '../../utils'

http = require 'http'
storage = require '../storage'
quote = require '../quote'
Sequelize = require 'sequelize'
{ inspect } = require 'util'
helpers = require './helpers'

app = null
server = null
QuoteVote = null

per_page = 10

merge = (objects...) ->
	target = {}
	for object in objects
		for key, value of object
			target[key] = value

	target

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
		
exports.init = promises (promise) -> (client) ->
	setup_models()

	express = require 'express'
	
	app = express()

	app.use express.static(__dirname + '/public')
	app.set 'views', __dirname + '/views'
	
	app.set 'view engine', 'ejs'
#	app.engine 'jinjs', jinjs.compile

	app.get '/', (req, res) ->
		quote.Quote.findAll(order: 'createdAt desc', limit: 25).success (quotes) ->
			res.render 'home', merge(helpers,
				quotes: quotes,
				active_page: 'home',
				chandata: client.chanData(require('../../config').channels[0])
			)
			
	app.get '/quotes', (req, res) ->
		page = 1
		quote.Quote.count().success (quote_count) ->
			page_max = Math.ceil quote_count / per_page
			quote.Quote.findAll
				order: 'createdAt desc',
				offset: (page - 1) * per_page
				limit: per_page
				
			.success (quotes) ->
				res.render 'quotes', merge(helpers,
					quotes: quotes,
					active_page: 'quotes',
					page: page,
					page_max: page_max
					term: null
				)
				
	app.get /\/search\/([^\/]+)\/page\/(\d+)/, (req, res) ->
		term = req.params[0]
		page = parseInt req.params[1]
		quote.Quote.count(where: ['quote LIKE ?', '%' + term + '%']).success (quote_count) ->
			if quote_count is 0
				res.render 'search-none', merge helpers, term: term, active_page: 'quotes'
			else
				page_max = Math.ceil quote_count / per_page
				quote.Quote.findAll
					order: 'createdAt desc',
					offset: (page - 1) * per_page,
					limit: per_page,
					where: ['quote LIKE ?', '%' + term + '%']
					
				.success (quotes) ->
					res.render 'quotes', merge(helpers,
						quotes: quotes,
						active_page: 'quotes',
						page: page,
						page_max: page_max,
						term: term
					)


				
	app.get /\/search\/([^\/]+)/, (req, res) ->
		term = req.params[0]
		page = 1
		quote.Quote.count(where: ['quote LIKE ?', '%' + term + '%']).success (quote_count) ->
			if quote_count is 0
				res.render 'search-none', merge helpers, term: term, active_page: 'quotes'
			else
				page_max = Math.ceil quote_count / per_page
				quote.Quote.findAll
					order: 'createdAt desc',
					offset: (page - 1) * per_page,
					limit: per_page,
					where: ['quote LIKE ?', '%' + term + '%']
					
				.success (quotes) ->
					res.render 'quotes', merge(helpers,
						quotes: quotes,
						active_page: 'quotes',
						page: page,
						page_max: page_max,
						term: term
					)
					
				
	app.get /\/quotes\/page\/(\d+)/, (req, res) ->
		page = parseInt req.params[0]
		quote.Quote.count().success (quote_count) ->
			page_max = Math.ceil quote_count / per_page
			quote.Quote.findAll
				order: 'createdAt desc',
				offset: (page - 1) * per_page
				limit: per_page
				
			.success (quotes) ->
				res.render 'quotes', merge(helpers,
					quotes: quotes,
					active_page: 'quotes',
					page: page,
					page_max: page_max,
					term: null
				)

	app.get /^\/vote\/(\d+)\/(up|down)/, (req, res) ->
		QuoteVote.findOrCreate({
			ip: req.ip, quote_id: parseInt req.params[0]
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