require 'rubygems'
require 'bundler/setup'
Bundler.require
if development?
  $stdout.sync = true
  require 'sinatra/reloader'
  $:.unshift File.expand_path '../lib', File.dirname(__FILE__)
end
require 'eventmachine'
require 'sinatra/websocketio'
require File.dirname(__FILE__)+'/main'

set :haml, :escape_html => true
set :websocketio, :port => 8080

run Sinatra::Application
