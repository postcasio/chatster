line_matcher = /<(.*?)>\s+(.*?)(?=\s*$|<(.*?)>)/g

class RGBColor
	constructor: (@r, @g, @b) ->
	
	toHSL: ->
		r = @r / 255
		g = @g / 255
		b = @b / 255
		
		h = s = l = 0
		
		min = Math.min r, g, b
		max = Math.max r, g, b
		d_max = max - min
	
		l = (max + min) / 2
		
		if d_max is 0
			new HSLColor 0, 0, l
			
		else
			if l < 0.5
				s = d_max / max + min
			else
				s = d_max / (2 - max - min)
	
			dr = (((max - r) / 6) + (d_max / 2)) / d_max
			dg = (((max - g) / 6) + (d_max / 2)) / d_max
			db = (((max - b) / 6) + (d_max / 2)) / d_max
			
			if r is max
				h = db - dg
			else if g is max
				h = (1 / 3) + dr - db
			else if b is max
				h = (2 / 3) + dg - dr
			
			if h < 0
				h += 1
			if h > 1
					h -= 1
					
			new HSLColor h, s, l
		
class HSLColor
	constructor: (@h, @s, @l) ->
	
	toCSS: ->
		h = Math.round(@h * 360)
		s = Math.round(@s * 100)
		l = Math.round(@l * 100)
		
		"hsl(#{h}, #{s}%, #{l}%)"
	
hashstr = (s) ->
	return 0 unless s.length > 0
	
	hash = 0
	
	for i in [0...s.length]
		c = s.charCodeAt i
		hash = ((hash << 5) - hash) + c
		hash |= 0
		
	Math.abs hash

nick_color = (nick) ->
	hash = (hashstr nick).toString(16).split('')
	new RGBColor(
		parseInt(hash.slice(0, 2), 16),
		parseInt(hash.slice(2, 4), 16),
		parseInt(hash.slice(4, 6), 16)
	)	

colorize = (nick) ->
	hsl = nick_color(nick).toHSL()

	hsl.s = Math.min(hsl.s * 2, 0.97)
	hsl.l = Math.min(0.5 + hsl.l, 0.77)
	
	"<span style=\"color: #{hsl.toCSS()};\">#{nick}</span>"
	
get_lines = (quote) ->
	console.log quote

	while result = line_matcher.exec quote
		('&lt;' + colorize(result[1]) + '&gt; ' + result[2] + '<br />')
		
exports.formatQuote = (quote) ->
	lines = get_lines(quote)
	lines.join ''
	
exports.quoteBorderColor = (quote) ->
	color = new RGBColor 0, 0, 0
	colors = 0
	
	while result = line_matcher.exec quote
		rgb = nick_color(result[1])
		color.r += rgb.r
		color.g += rgb.g
		color.b += rgb.b
		colors++
		
	color.r /= colors
	color.g /= colors
	color.b /= colors
	
	hsl = color.toHSL()
	
	hsl.s = 0.2
	hsl.l = Math.min(0.5 + hsl.l, 0.77)
	
	hsl.toCSS()