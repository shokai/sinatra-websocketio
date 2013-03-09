module EventMachine
  module WebSocketIO
    class Client
      include EventEmitter
      attr_reader :url, :session
      attr_accessor :timeout

      def initialize(url)
        raise ArgumentError, "invalid websocket URL \"#{url}\"" unless url =~ /^ws:\/\/.+/
        @url = url
        self.on :__session_id do |session_id|
          @session = session_id
          self.emit :connect, session_id
        end
      end

      def connect
        url = @session ? "#{@url}/session=#{@session}" : @url
        @ws = EventMachine::WebSocketClient.connect url

        @ws.stream do |msg|
          data = JSON.parse msg
          self.emit data['type'], data['data']
        end

        @ws.callback do
          self.push :__session_id, nil
        end

        @ws.errback do |err|
          self.emit :error, err
        end

        @ws.disconnect do
          self.emit :disconnect
          EM::add_timer 10 do
            connect
          end
        end

        return self
      end

      def push(type, data={})
        @ws.send_msg({:type => type, :data => data, :session => self.session}.to_json)
      end

    end
  end
end
