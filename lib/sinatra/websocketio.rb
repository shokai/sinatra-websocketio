require 'eventmachine'
require 'em-websocket'
require 'json'
require 'digest/md5'
require 'event_emitter'
require 'sinatra/streaming'
require File.expand_path '../sinatra-websocketio/version', File.dirname(__FILE__)
require File.expand_path '../sinatra-websocketio/websocketio', File.dirname(__FILE__)
require File.expand_path '../sinatra-websocketio/application', File.dirname(__FILE__)

Sinatra.register Sinatra::WebSocketIO
WebSocketIO.start
