require 'rubygems'
require 'minitest/autorun'
require 'em-websocketio-client'
require File.expand_path 'app', File.dirname(__FILE__)

$:.unshift File.expand_path '../lib', File.dirname(__FILE__)

['SIGHUP', 'SIGINT', 'SIGKILL', 'SIGTERM'].each do |sig|
  Kernel.trap sig do
    App.stop
  end
end
