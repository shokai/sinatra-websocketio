class App

  def self.running
    @running ? true : false
  end

  def self.port
    ENV['PORT'] || 5000
  end

  def self.ws_port
    ENV['WS_PORT'] || 8080
  end

  def self.websocketio_url
    "ws://localhost:#{ws_port}"
  end

  def self.pid_file
    ENV['PID_FILE'] || "/tmp/sinatra-cometio-testapp.pid"
  end

  def self.app_dir
    File.expand_path 'app', File.dirname(__FILE__)
  end

  def self.pid
    return unless @running
    File.open(pid_file) do |f|
      pid = f.gets.strip.to_i
      return pid if pid > 0
    end
    return
  end

  def self.start
    return if @running
    File.delete pid_file if File.exists? pid_file
    Thread.new do
      IO::popen "cd #{app_dir} && PID_FILE=#{pid_file} rackup config.ru -p #{port} > /dev/null 2>&1"
    end
    @running = true
    100.times do
      if File.exists? pid_file
        sleep 1
        return true
      end
      sleep 0.1
    end
    @running = false
    return false
  end

  def self.stop
    return unless @running
    system "kill #{pid}"
    File.delete pid_file if File.exists? pid_file
    @running = false
  end

end
