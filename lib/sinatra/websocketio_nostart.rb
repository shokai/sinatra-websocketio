require 'eventmachine'
require 'em-websocket'
require 'json'
require 'digest/md5'
require 'event_emitter'
require 'sinatra/streaming'
require File.expand_path '../sinatra-websocketio/version', File.dirname(__FILE__)
require File.expand_path '../sinatra-websocketio/helpers', File.dirname(__FILE__)
require File.expand_path '../sinatra-websocketio/options', File.dirname(__FILE__)
require File.expand_path '../sinatra-websocketio/websocketio', File.dirname(__FILE__)
require File.expand_path '../sinatra-websocketio/javascript', File.dirname(__FILE__)
require File.expand_path '../sinatra-websocketio/application', File.dirname(__FILE__)

module Sinatra
  module WebSocketIO
  end
  register WebSocketIO
end
