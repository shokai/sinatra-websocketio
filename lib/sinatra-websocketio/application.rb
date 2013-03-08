
module Sinatra::WebSocketIO

  def websocketio=(options)
    WebSocketIO.options = options
  end

  def websocketio
    WebSocketIO.options
  end

  helpers do
    def websocketio_js
      "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}/websocketio/websocketio.js"
    end

    def websocketio_url
      "ws://#{env['SERVER_NAME']}:#{WebSocketIO.options[:port]}"
    end
  end

  get '/websocketio/websocketio.js' do
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
