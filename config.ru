require 'rubygems'
require 'bundler'

Bundler.require

require './app.rb'

map root('/') do
  run Sinatra::Application
end
