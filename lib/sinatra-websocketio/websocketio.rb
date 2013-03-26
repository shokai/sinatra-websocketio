module Sinatra
  module WebSocketIO

    @@running = false
    def self.running?
      @@running
    end

    def self.start
      return if running?
      @@running = true
      EM::defer do
        while !EM::reactor_running? do
          sleep 1
        end
        puts "Sinatra::WebSocketIO.start port:#{options[:port]}"
        EM::WebSocket.run :host => "0.0.0.0", :port => options[:port] do |ws|
          ws.onopen do |handshake|
            params = parse_handshake_params handshake.path
            session_id = params[:session] || (create_session Socket.unpack_sockaddr_in ws.get_peername)

            if self.sessions.include? session_id
              ws.send({:type => :error, :data => "invalid session_id (#{session_id})"}.to_json)
              ws.close
            else
              self.sessions[session_id] = ws
              ws.onclose do
                self.sessions.delete session_id
                self.emit :disconnect, session_id
              end
              ws.onmessage do |msg|
                begin
                  data = ::JSON.parse msg
                rescue => e
                  self.emit :error, e
                end
                self.emit data['type'], data['data'], session_id if data
              end
              ws.send({:type => :__session_id, :data => session_id}.to_json)
              self.emit :connect, session_id
            end

          end
        end
      end
    end

    def self.push(type, data, opt={})
      session_ids = opt[:to].to_s.empty? ? self.sessions.keys : [opt[:to]]
      if opt.include? :to
        return unless self.sessions.include? opt[:to]
        s = self.sessions[opt[:to]]
        begin
          s.send({:type => type, :data => data}.to_json)
        rescue => e
          emit :error, "websocketio push error (session:#{opt[:to]})"
        end
        return
      end
      self.sessions.keys.each do |id|
        push type, data, :to => id
      end
    end

    def self.sessions
      @@sessions ||= Hash.new
    end

    def self.create_session(ip_addr)
      Digest::MD5.hexdigest "#{Time.now.to_i}_#{Time.now.usec}_#{ip_addr}"
    end

    def self.parse_handshake_params(path)
      tmp = path.gsub(/^\//,'').split(/\=+/)
      params = {}
      while !tmp.empty?
        params[tmp.shift.to_sym] = tmp.shift
      end
      params
    end

  end
end

EventEmitter.apply Sinatra::WebSocketIO
Sinatra::WebSocketIO.on :__session_id do |data, from|
  push :__session_id, from, :to => from
end

