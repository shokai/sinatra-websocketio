sinatra-websocketio
===================
WebSocket component for [Sinatra RocketIO](https://github.com/shokai/sinatra-rocketio)

* Node.js like WebSocket I/O plugin for Sinatra
* https://github.com/shokai/sinatra-websocketio
* https://github.com/shokai/sinatra-websocketio/wiki
* [Handle 10K+ clients on 1 process](https://github.com/shokai/sinatra-websocketio/wiki/C10K)


Installation
------------

    % gem install sinatra-websocketio


Requirements
------------
* Ruby 1.8.7 or 1.9.2 or 1.9.3 or 2.0.0
* Sinatra 1.3.0+
* EventMachine
* jQuery


Usage
-----


### Server --(WebSocket)--> Client

Server Side

```ruby
require 'sinatra'
require 'sinatra/websocketio'
set :websocketio, :port => 8080

run Sinatra::Application
```
```ruby
io = Sinatra::WebSocketIO

io.push :temperature, 35  # to all clients
io.push :light, {:value => 150}, {:to => session_id} # to specific client
```

Client Side

```html
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="<%= websocketio_js %>"></script>
```
```javascript
var io = new WebSocketIO().connect();
io.on("temperature", function(value){
  console.log("server temperature : " + value);
}); // => "server temperature : 35"
io.on("light", function(data){
  console.log("server light sensor : " + data.value);
}); // => "server light sensor : 150"
```


### Client --(WebSocket)--> Server

Client Side

```javascript
io.on("connect", function{
  io.push("chat", {name: "shokai", message: "hello"}); // client -> server
});
```

Server Side

```ruby
io.on :chat do |data, session|
  puts "#{data['name']} : #{data['message']}  <#{session}>"
end
## => "shokai : hello  <12abcde345f6g7h8ijk>"
```

### On "connect" Event

Client Side

```javascript
io.on("connect", function(session){
  alert("connect!!");
});

io.on("disconnect", function(){
  alert("disconnected");
});
```

Server Side

```ruby
io.on :connect do |session|
  puts "new client <#{session}>"
  io.push :hello, "hello!!"
end

io.on :disconnect do |session|
  puts "client disconnected <#{session}>"
end
```

### On "error" Event

Client Side

```javascript
io.on("error", function(err){
  console.error(err);
});
```

Server Side
```ruby
io.on :error do |e|
  STDERR.puts e
end
```

### Remove Event Listener

Server Side

```ruby
event_id = io.on :chat do |data, from|
  puts "#{data} - from#{from}"
end
io.removeListener event_id
```

or

```ruby
io.removeListener :chat  # remove all "chat" listener
```


Client Side

```javascript
var event_id = io.on("error", function(err){
  console.error("WebSocketIO error : "err);
});
io.removeListener(event_id);
```

or

```javascript
io.removeListener("error");  // remove all "error" listener
```


### Config

```ruby
set :websocketio, :port => 8080
```
or

    % WS_PORT=8080 rackup config.ru



Sample App
----------
chat app

- https://github.com/shokai/sinatra-websocketio/tree/master/sample


Test
----

    % gem install bundler
    % bundle install
    % export PORT=5000
    % export WS_PORT=8080
    % export PID_FILE=/tmp/sinatra-websocketio-test.pid
    % rake test


Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
