base64DecodeStream
============

Correctly decode base64 streamed content into any encoded('utf8', 'hex', 'acsii' and even 'base64') string (Node.js written in CoffeeScript).

This module is referenced to https://github.com/cjblomqvist/base64Stream.git

## Usage ##

```
npm install
```

```coffee
request = require 'request'

decoder = (require 'base64DecodeStream').Base64StreamToString
decoderStream = new decoder 'utf8'

# need VPN if you live in China mainland.
gfwlistUrl = 'http://autoproxy-gfwlist.googlecode.com/svn/trunk/gfwlist.txt'

request.get(gfwlistUrl).pipe(decoderStream).pipe(process.stdout)

```

## MIT License
Copyright (c) 2012 by Carl-Johan Blomqvist

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.