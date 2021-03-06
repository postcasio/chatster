storage = require '../storage'
{ promises, filtered } = require('../../utils')
irc = require 'irc'

youtube = require 'youtube-feeds'

client = null

bold = String.fromCharCode(0x02)
underline = String.fromCharCode(0x1F)

round = (n) -> Math.round(n*100)/100
duration = (n) ->
	minutes = Math.floor(n / 60)
	seconds = n % 60
	
	return minutes + ':' + (if seconds < 10 then '0' else '') + seconds

youtube_info = filtered text: /(?:youtu.be\/|\/v\/|\/u\/\w\/|\/embed\/|\/watch\?v=)([^#\&\?]*)/i,
	(from, to, text, message, match) ->
		console.log 'fetching video info ' + match[1]
		youtube.video(match[1]).details (e, vid) ->
			str = bold + vid.title + bold + " ["
			str += duration(vid.duration) + "]"
			if vid.likeCount and vid.ratingCount
				str += " ("
				str += irc.colors.wrap('dark_green', vid.likeCount + "👍") + " "
				str += irc.colors.wrap('dark_red', (vid.ratingCount - vid.likeCount) + "👎")
				str += ")"
			
				
			client.say to, str
		
exports.unload = ->
	client.removeListener 'message', youtube_info
	
exports.init = promises (promise) -> (c) ->
	client = c
	
	client.on 'message', youtube_info
			
	promise.resolve()