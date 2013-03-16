module Sinatra
  module WebSocketIO

    def self.javascript(*js_file_names)
      js_file_names = ['websocketio.js', 'event_emitter.js'] if js_file_names.empty?
      js = ''
      js_file_names.each do |i|
        File.open(File.expand_path "../js/#{i}", File.dirname(__FILE__)) do |f|
          js += f.read
        end
      end
      js
    end

  end
end
