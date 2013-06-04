var WebSocketIO = function(url, opts){
  new EventEmitter().apply(this);
  if(typeof opts === "undefined" || opts === null) opts = {};
  this.url = url || "<%= websocketio_url %>";
  this.session = opts.session || null;
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
    if(typeof WebSocket === "undefined"){
      self.emit("error", "websocket not exists in this browser");
      return null;
    }
    self.running = true;
    var url = self.session ? self.url+"/session="+self.session : self.url;
    self.websocket = new WebSocket(url);
    self.websocket.onmessage = function(e){
      var data_ = null;
      try{
        data_ = JSON.parse(e.data);
      }
      catch(e){
        self.emit("error", "WebSocketIO data parse error");
      }
      if(!!data_) self.emit(data_.type, data_.data);
    };
    self.websocket.onclose = function(){
      if(self.connecting){
        self.connecting = false;
        self.emit("disconnect");
      }
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
    if(!self.connecting){
      self.emit("error", "websocket not connected");
      return;
    }
    self.websocket.send(JSON.stringify({type: type, data: data, session: self.session}));
  };
};
