require 'rubygems'
require 'bundler'
Bundler.require
$stdout.sync = true
$:.unshift File.expand_path '../../lib', File.dirname(__FILE__)
require 'sinatra'
require 'sinatra/websocketio'
require File.dirname(__FILE__)+'/main'

set :websocketio, :port => ENV['WS_PORT'].to_i

run TestApp
