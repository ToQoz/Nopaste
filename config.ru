require 'rubygems'
require 'bundler'

Bundler.require

require './app.rb'

map '/nopaste' do
  run Sinatra::Application
end
