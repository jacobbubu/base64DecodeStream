stream = require("stream")
util = require("util")

Base64StreamToString = (toEncoding) ->
  @toEncoding = toEncoding ? 'utf8'
  @oddString = ''
  @sentOdd = false
  @chunks = []
  @size = 0

  @writable = true
  @readable = true
  @paused = false

util.inherits Base64StreamToString, stream.Stream

Base64StreamToString::pipe = (dest, options) ->
  self = this
  self.resume() if self.resume

  stream.Stream::pipe.call self, dest, options

  #just incase you are piping to two streams, do not emit data twice.
  #note: you can pipe twice, but you need to pipe both streams in the same tick.
  #(this is normal for streams)
  return dest if @piped
  
  process.nextTick ->
    self.emitAllBufferedChunks()

  @piped = true
  dest

Base64StreamToString::write = (chunk) ->  
  if @chunks.length is 0 and not @paused
    @emit "data", @getBase64Chunk(chunk).toString(@toEncoding)
    return

  @chunks.push chunk
  @size += chunk.length

Base64StreamToString::end = ->
  if @chunks.length is 0 and not @paused
    
    # If there are any remaining data not encoded, we need to encode it and send it now
    if @oddString.length > 0 and not @sentOdd
      console.log 'oddString', @oddString
      @emit "data", (new Buffer @oddString, 'base64').toString(@toEncoding)
      @sentOdd = true
    
    # In case a pause is triggered after oddString been emitted, we can't end just yet
    if @paused
      @ended = true
    else
      @emit "end"
  else
    @ended = true

unless stream.Stream::pause
  Base64StreamToString::pause = ->
    @paused = true
    @emit "pause"

unless stream.Stream::resume
  Base64StreamToString::resume = ->
    @paused = false
    @emitAllBufferedChunks()
    @emit "resume"

Base64StreamToString::getBase64Chunk = (chunk) ->
  # Ensure we are dealing with a buffer

  if Buffer.isBuffer(chunk)
    decodedString = chunk.toString()
  else
    decodedString = chunk

  decodedString = decodedString.replace(/[\r\n]/g, '')
  decodedString = @oddString + decodedString
  
  remainLength = decodedString.length % 4
  @oddString = if remainLength > 0 then decodedString.slice(-remainLength) else ''
  decodedString = decodedString.slice 0, decodedString.length - remainLength
  new Buffer decodedString, 'base64'

Base64StreamToString::emitAllBufferedChunks = ->
  self = this
  
  # Loop through all chunks and try to emit the data - return true if all chunks have been processed, otherwise false (if paused somewhere along the processing)
  emitChunk = ->
    return false if self.paused

    chunk = self.chunks.shift()

    return true unless chunk

    self.size -= chunk.length
    self.emit "data", self.getBase64Chunk(chunk).toString(self.toEncoding)
    emitChunk()

  if emitChunk() and @ended
    
    # If there are any remaining data not encoded, we need to encode it and send it now
    if @oddString.length > 0 and not @sentOdd
      @emit "data", (new Buffer @oddString).toString(@toEncoding)
      @sentOdd = true
      
      # In case a pause is triggered after oddString been emitted, end here
      return unless @paused
    @emit "end"

exports.Base64StreamToString = Base64StreamToString
