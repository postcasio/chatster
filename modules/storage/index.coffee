promises = require('../../utils').promises
Sequelize = require 'sequelize'

exports.db = null

exports.unload = ->

exports.init = promises (promise) -> (client) ->
 exports.db = new Sequelize 'storage.db', 'cwbot', 'cwbot',
 	dialect: 'sqlite'
 	storage: 'storage.db'
 promise.resolve()