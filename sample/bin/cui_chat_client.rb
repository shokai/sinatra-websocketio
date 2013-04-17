#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
$:.unshift File.expand_path '../../lib', File.dirname(__FILE__)
require 'eventmachine'
require 'sinatra/websocketio/client'

name = `whoami`.strip || 'shokai'

client = Sinatra::WebSocketIO::Client.new('ws://localhost:9000').connect

client.on :connect do |session|
  puts "connect!! (session_id:#{session})"
end

client.on :chat do |data|
  puts "<#{data['name']}> #{data['message']}"
end

client.on :error do |err|
  STDERR.puts err
end

client.on :disconnect do
  puts "disconnected!!"
end

loop do
  line = STDIN.gets.strip
  next if line.empty?
  client.push :chat, {:message => line, :name => name}
end
