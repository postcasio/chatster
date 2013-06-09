{ promises, filtered } = require('../../utils')
config = require '../../config'

irc = require 'irc'
loaded_modules = {}
client = null
root = null

load_modules = (list, place=0, send_to=null) ->
	if list.length == place
		return
		
	module = list[place]
	
	console.log "Loading module", module
	loaded_modules[module] = require '../' + module
	loaded_modules[module].init(client).then ->
		load_modules list, place + 1, send_to

reload = filtered text: /^\.reload$/,
	(from, to, text, message) ->
		reply_to = (if to is config.botName then from else to)
		client.say reply_to, "Reloading modules..."
		
		for k, m of loaded_modules
			m.unload()
			path = require.resolve '../' + k
			delete require.cache[path]
			
		delete require.cache[require.resolve '../../config']
		
		config = require '../../config'
		loaded_modules = {}

		root.reload_system(reply_to)

exports.unload = ->
	client.removeListener 'message', reload

exports.init = promises (promise) -> (c, r, s) ->
	client = c
	root = r
	
	client.on 'message', reload
	
	load_modules(config.modules, 0, s).then ->
		if s
			client.say s, "Loaded modules: " + config.modules.join(', ')
	
	promise.resolve()