module Sinatra
  module WebSocketIO
    module Helpers

      def websocketio_js
        "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}/websocketio/websocketio.js"
      end

      def websocketio_url
        "ws://#{env['SERVER_NAME']}:#{WebSocketIO.options[:port]}"
      end

    end
  end
end
