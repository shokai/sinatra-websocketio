var WebSocketIO = function(){
  new EventEmitter().apply(this);
  this.url = "<%= websocketio_url %>";
  this.session = null;
  this.websocket = null;
  this.connecting = false;
  var reconnect_timer_id = null;
  var running = false;
  var self = this;

  self.on("__session_id", function(session_id){
    self.session = session_id;
    self.emit("connect", self.session);
  });

  this.connect = function(){
    if(typeof WebSocket === 'undefined'){
      self.emit("error", "websocket not exists");
      return null;
    }
    self.running = true;
    self.websocket = new WebSocket(self.url);
    self.websocket.onmessage = function(e){
      try{
        var data_ = JSON.parse(e.data);
        self.emit(data_.type, data_.data);
      }
      catch(e){
        self.emit("error", "WebSocketIO get error");
      }
    };
    self.websocket.onclose = function(){
      if(self.connecting) self.emit("disconnect");
      self.connecting = false;
      if(self.running){
        reconnect_timer_id = setTimeout(self.connect, 10000);
      }
    };
    self.websocket.onopen = function(){
      self.connecting = true;
    };
    return self;
  };

  this.close = function(){
    clearTimeout(reconnect_timer_id);
    self.running = false;
    self.websocket.close();
  };

  this.push = function(type, data){
    self.websocket.send(JSON.stringify({type: type, data: data, session: self.session}));
  };
};
