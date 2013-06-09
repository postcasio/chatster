irc = require 'irc'
config = require './config'
{ filtered } = require './utils'
	
bot = new irc.Client config.server, config.botName, channels: config.channels

system = null

exports.reload_system = (reply_to=null) ->
	if require.cache[require.resolve './modules/system']
		system.unload()
		delete require.cache[require.resolve './modules/system']
		
	system = require './modules/system'
	
	system.init bot, exports, reply_to
	
exports.reload_system()