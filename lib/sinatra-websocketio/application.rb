module Sinatra
  module WebSocketIO

    def self.registered(app)
      app.helpers Sinatra::WebSocketIO::Helpers

      app.get '/websocketio/websocketio.js' do
        content_type 'application/javascript'
        @js ||= ERB.new(Sinatra::WebSocketIO.javascript).result(binding)
      end
    end

  end
end
