irc = require 'irc'
config = require './config'
	
bot = new irc.Client config.server, config.botName, channels: config.channels

loaded_modules = {}

load_modules = (list, place=0) ->
	if list.length == place
		return
		
	module = list[place]
	console.log "Loading module", module	
	loaded_modules[module] = require './modules/' + module
	loaded_modules[module].init(bot).then ->
		load_modules list, place + 1
		
load_modules config.modules