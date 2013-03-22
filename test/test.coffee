request = require 'request'

decoder = (require '../src/index.coffee').Base64StreamToString
decoderStream = new decoder 'utf8'

# need VPN if you live in China mainland.
gfwlistUrl = 'http://autoproxy-gfwlist.googlecode.com/svn/trunk/gfwlist.txt'

request.get(gfwlistUrl).pipe(decoderStream).pipe(process.stdout)
