class ChatApp < Sinatra::Base
  register Sinatra::WebSocketIO
  io = Sinatra::WebSocketIO

  io.on :connect do |session|
    puts "new client <#{session}>"
    push :chat, {:name => "system", :message => "new client <#{session}> / #{io.sessions.size} clients connecting"}
    push :chat, {:name => "system", :message => "welcome <#{session}>"}, {:to => session}
  end

  io.on :disconnect do |session|
    puts "disconnect client <#{session}>"
    push :chat, {:name => "system", :message => "bye <#{session}>"}
  end

  io.on :chat do |data, from|
    puts "#{data['name']} : #{data['message']}  (from:#{from})"
    push :chat, data
  end

  io.on :error do |err|
    STDERR.puts "error!! #{err}"
  end

  get '/' do
    haml :index
  end

  get '/:source.css' do
    scss params[:source].to_sym
  end
end
