module Sinatra
  module WebSocketIO

    def websocketio=(options)
      WebSocketIO.options = options
    end

    def websocketio
      WebSocketIO.options
    end

    def self.registered(app)
      app.helpers Sinatra::WebSocketIO::Helpers

      app.get '/websocketio/websocketio.js' do
        content_type 'application/javascript'
        @js ||= (
                 js = ''
                 Dir.glob(File.expand_path '../js/*.js', File.dirname(__FILE__)).each do |i|
                   File.open(i) do |f|
                     js += f.read
                   end
                 end
                 ERB.new(js).result(binding)
                 )
      end
    end

  end
end
