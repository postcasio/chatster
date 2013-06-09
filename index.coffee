irc = require 'irc'
config = require './config'
{ filtered } = require './utils'
	
bot = new irc.Client config.server, config.botName, channels: config.channels

loaded_modules = {}

load_modules = (list, place=0, send_to=null) ->
	if list.length == place
		return
		
	module = list[place]
	if send_to
		bot.say send_to, "Loading module " + module
	else
		console.log "Loading module", module
	loaded_modules[module] = require './modules/' + module
	loaded_modules[module].init(bot).then ->
		load_modules list, place + 1, send_to
		
reload_modules = (from) ->
	for k, m of loaded_modules
		m.unload()
		path = require.resolve './modules/' + k
		delete require.cache[path]
		
	delete require.cache[require.resolve './config']
	config = require './config'
	
	loaded_modules = {}
	load_modules config.modules, 0, from
		
bot.on 'message', filtered text: /^\.reload$/, (from, to, text, message) ->
	bot.say from, 'Reloading modules...'
	reload_modules(from).then ->
		bot.say from, 'Done.'

load_modules config.modules