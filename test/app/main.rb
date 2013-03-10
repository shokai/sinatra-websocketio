pid_file = ENV['PID_FILE'] || "/tmp/sinatra-websocketio-test-pid"
File.open(pid_file, "w+") do |f|
  f.write Process.pid.to_s
end

class TestApp < Sinatra::Application

  get '/' do
    "sinatra-websocketio v#{Sinatra::WebSocketIO::VERSION}"
  end

  WebSocketIO.on :connect do |session|
    puts "new client <#{session}>"
  end

  WebSocketIO.on :disconnect do |session|
    puts "disconnect client <#{session}>"
  end

  WebSocketIO.on :broadcast do |data, from|
    puts from
    puts "broadcast <#{from}> - #{data.to_json}"
    push :broadcast, data
  end

  WebSocketIO.on :message do |data, from|
    puts "message <#{from}> - #{data.to_json}"
    push :message, data, :to => data['to']
  end

end
