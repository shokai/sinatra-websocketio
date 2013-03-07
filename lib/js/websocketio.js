var WebSocketIO = function(){
  new EventEmitter().apply(this);
  this.url = "<%= websocketio_url %>";
  this.session = null;
  this.websocket = null;
  var running = false;
  var self = this;

  this.connect = function(){
    self.websocket = new WebSocket(self.url);
    self.websocket.onmessage = function(e){
      try{
        var data_ = JSON.parse(e.data);
        console.log(data_);
        self.emit(data_.type, data_.data);
      }
      catch(e){
        self.emit("error", "WebSocketIO get error");
      }
    };
    self.websocket.onclose = function(){
      self.emit("error", "WebSocketIO closed");
    };
    self.websocket.onopen = function(){
      self.on("__session_id", function(session_id){
        self.session = session_id;
        self.emit("connect", self.session);
      });
    };
    return self;
  };

  this.push = function(type, data){
    self.websocket.send(JSON.stringify({type: type, data: data, session: self.session}));
  };
};
