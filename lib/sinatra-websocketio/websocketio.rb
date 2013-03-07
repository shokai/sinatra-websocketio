class WebSocketIO

  def self.port
    @@port ||= 8080
  end

  def self.start(port=8080)
    @@port = port
    EM::defer do
      while !EM::reactor_running? do
        sleep 1
      end
      puts "WebSocketIO.start port:#{port}"
      EM::WebSocket.run :host => "0.0.0.0", :port => port do |ws|
        ip_addr = Socket.unpack_sockaddr_in ws.get_peername
        session_id = create_session ip_addr
        ws.onopen do |handshake|
          self.sessions[session_id] = {
            :websocket => ws
          }
          ws.send({:type => :__session_id, :data => session_id}.to_json)
          self.emit :connect, session_id
        end

        ws.onclose do
          self.emit :disconnect, session_id
        end
        
        ws.onmessage do |msg|
          begin
            data = JSON.parse msg
          rescue => e
            self.emit :error, e
          end
          self.emit data['type'], data['data'], session_id if data
        end
      end
    end
  end

  def self.push(type, data)
    sessions.each do |session_id, h|
      h[:websocket].send({:type => type, :data => data}.to_json)
    end
  end

  def self.sessions
    @@sessions ||= Hash.new{|h,session_id|
      h[session_id] = {
        :websocket => nil
      }
    }
  end

  def self.create_session(ip_addr)
    Digest::MD5.hexdigest "#{Time.now.to_i}_#{Time.now.usec}_#{ip_addr}"
  end

end
EventEmitter.apply WebSocketIO


