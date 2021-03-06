// Generated by CoffeeScript 1.6.2
var Base64StreamToString, stream, util;

stream = require("stream");

util = require("util");

Base64StreamToString = function(toEncoding) {
  this.toEncoding = toEncoding != null ? toEncoding : 'utf8';
  this.oddString = '';
  this.sentOdd = false;
  this.chunks = [];
  this.size = 0;
  this.writable = true;
  this.readable = true;
  return this.paused = false;
};

util.inherits(Base64StreamToString, stream.Stream);

Base64StreamToString.prototype.pipe = function(dest, options) {
  var self;

  self = this;
  if (self.resume) {
    self.resume();
  }
  stream.Stream.prototype.pipe.call(self, dest, options);
  if (this.piped) {
    return dest;
  }
  process.nextTick(function() {
    return self.emitAllBufferedChunks();
  });
  this.piped = true;
  return dest;
};

Base64StreamToString.prototype.write = function(chunk) {
  if (this.chunks.length === 0 && !this.paused) {
    this.emit("data", this.getBase64Chunk(chunk).toString(this.toEncoding));
    return;
  }
  this.chunks.push(chunk);
  return this.size += chunk.length;
};

Base64StreamToString.prototype.end = function() {
  if (this.chunks.length === 0 && !this.paused) {
    if (this.oddString.length > 0 && !this.sentOdd) {
      console.log('oddString', this.oddString);
      this.emit("data", (new Buffer(this.oddString, 'base64')).toString(this.toEncoding));
      this.sentOdd = true;
    }
    if (this.paused) {
      return this.ended = true;
    } else {
      return this.emit("end");
    }
  } else {
    return this.ended = true;
  }
};

if (!stream.Stream.prototype.pause) {
  Base64StreamToString.prototype.pause = function() {
    this.paused = true;
    return this.emit("pause");
  };
}

if (!stream.Stream.prototype.resume) {
  Base64StreamToString.prototype.resume = function() {
    this.paused = false;
    this.emitAllBufferedChunks();
    return this.emit("resume");
  };
}

Base64StreamToString.prototype.getBase64Chunk = function(chunk) {
  var decodedString, remainLength;

  if (Buffer.isBuffer(chunk)) {
    decodedString = chunk.toString();
  } else {
    decodedString = chunk;
  }
  decodedString = decodedString.replace(/[\r\n]/g, '');
  decodedString = this.oddString + decodedString;
  remainLength = decodedString.length % 4;
  this.oddString = remainLength > 0 ? decodedString.slice(-remainLength) : '';
  decodedString = decodedString.slice(0, decodedString.length - remainLength);
  return new Buffer(decodedString, 'base64');
};

Base64StreamToString.prototype.emitAllBufferedChunks = function() {
  var emitChunk, self;

  self = this;
  emitChunk = function() {
    var chunk;

    if (self.paused) {
      return false;
    }
    chunk = self.chunks.shift();
    if (!chunk) {
      return true;
    }
    self.size -= chunk.length;
    self.emit("data", self.getBase64Chunk(chunk).toString(self.toEncoding));
    return emitChunk();
  };
  if (emitChunk() && this.ended) {
    if (this.oddString.length > 0 && !this.sentOdd) {
      this.emit("data", (new Buffer(this.oddString)).toString(this.toEncoding));
      this.sentOdd = true;
      if (!this.paused) {
        return;
      }
    }
    return this.emit("end");
  }
};

exports.Base64StreamToString = Base64StreamToString;
