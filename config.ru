require 'rubygems'
require 'bundler'

Bundler.require

require './app.rb'

map '/Nopaste' do
  run Sinatra::Application
end
