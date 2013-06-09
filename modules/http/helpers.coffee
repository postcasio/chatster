
hashstr = (s) ->
	return 0 unless s.length > 0
	
	hash = 0
	
	for i in [0...s.length]
		c = s.charCodeAt i
		hash = ((hash << 5) - hash) + c
		hash |= 0
		
	Math.abs hash
	
rgb_to_hsl = (r, g, b) ->
	r = r / 255
	g = g / 255
	b = b / 255
	
	h = s = l = 0
	
	min = Math.min r, g, b
	max = Math.max r, g, b
	d_max = max - min

	l = (max + min) / 2
	
	if d_max is 0
		return [0, 0, l]
		
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
			
		s = Math.min(s * 2, 0.97)
		l = Math.min(0.5 + l, 0.77)
	
		return [Math.round(h * 360, 2), Math.round(s * 100, 2) + '%', Math.round(l * 100, 2) + '%']

colorize = (n) ->
	hash = (hashstr n).toString(16).split('')
	
	r = parseInt hash.slice(0, 2).join(''), 16
	g = parseInt hash.slice(2, 4).join(''), 16
	b = parseInt hash.slice(4, 6).join(''), 16
	console.log r, g, b
	hsl = rgb_to_hsl r, g, b
	
	'<span style="color: hsl(' + hsl.join(',') + ');">' + n + '</span>'

get_lines = (quote) ->
	console.log quote
	line_matcher = /<(.*?)>\s+(.*?)(?=\s*$|<(.*?)>)/g

	while result = line_matcher.exec quote
		('&lt;' + colorize(result[1]) + '&gt; ' + result[2] + '<br />')
		
exports.formatQuote = (quote) ->
	lines = get_lines(quote)
	lines.join ''
#	quote.replace /<[^>]>/g, (match) ->
#		"<br />" + match