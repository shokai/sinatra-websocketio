WebSocketIO.on :connect do |session|
  puts "new client <#{session}>"
  WebSocketIO.push :chat, {:name => "system", :message => "new client <#{session}>"}
  WebSocketIO.push :chat, {:name => "system", :message => "welcome <#{session}>"}, {:to => session}
end

WebSocketIO.on :disconnect do |session|
  puts "disconnect client <#{session}>"
  WebSocketIO.push :chat, {:name => "system", :message => "bye <#{session}>"}
end

WebSocketIO.on :chat do |data, from|
  puts "#{data['name']} : #{data['message']}  (from:#{from})"
  WebSocketIO.push :chat, data
end

WebSocketIO.on :error do |err|
  STDERR.puts "error!! #{err}"
end

get '/' do
  haml :index
end

get '/:source.css' do
  scss params[:source].to_sym
end
