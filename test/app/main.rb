class TestApp < Sinatra::Base
  register Sinatra::WebSocketIO
  io = Sinatra::WebSocketIO

  get '/' do
    "sinatra-websocketio v#{Sinatra::WebSocketIO::VERSION}"
  end

  io.on :connect do |session|
    puts "new client <#{session}>"
  end

  io.on :disconnect do |session|
    puts "disconnect client <#{session}>"
  end

  io.on :broadcast do |data, from|
    puts from
    puts "broadcast <#{from}> - #{data.to_json}"
    push :broadcast, data
  end

  io.on :message do |data, from|
    puts "message <#{from}> - #{data.to_json}"
    push :message, data, :to => data['to']
  end

end
