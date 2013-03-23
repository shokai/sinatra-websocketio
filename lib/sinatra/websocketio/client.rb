require File.expand_path '../../sinatra-websocketio/version', File.dirname(__FILE__)
require 'websocket-client-simple'
require 'event_emitter'
require 'json'
require 'timeout'

module Sinatra
  module WebSocketIO
    class Client
      class Error < StandardError
      end

      include EventEmitter
      attr_reader :url, :session
      attr_accessor :running, :connecting, :timeout

      def initialize(url)
        @url = url
        @session = nil
        @websocket = nil
        @connecting = false
        @running = false
        @timeout = 5

        on :__session_id do |session_id|
          @session = session_id
          emit :connect, @session
        end
      end

      def connect
        return self if connecting
        this = self
        @running = true
        url = @session ? "#{@url}/session=#{@session}" : @url
        @websocket = nil
        begin
          @websocket = WebSocket::Client::Simple::Client.new url
        rescue StandardError, Timeout::Error => e
          Thread.new do
            sleep 5
            connect
          end
        end
        return self unless @websocket

        @websocket.on :message do |msg|
          begin
            data = JSON.parse msg.data
            this.emit data['type'], data['data']
          rescue => e
            this.emit :error, e
          end
        end

        @websocket.on :close do |e|
          if this.connecting
            this.connecting = false
            this.emit :disconnect, e
          end
          if this.running
            Thread.new do
              sleep 5
              this.connect
            end
          end
        end

        @websocket.on :open do
          this.connecting = true
        end

        return self
      end

      def close
        @running = false
        @websocket.close
      end

      def push(type, data)
        if !@connecting
          emit :error, 'websocket not connecting'
          return
        end
        begin
          Timeout::timeout @timeout do
            @websocket.send({:type => type, :data => data, :session => @session}.to_json)
          end
        rescue Timeout::Error, StandardError => e
          emit :error, e
        end
      end

    end
  end
end
