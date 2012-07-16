require 'rubygems'
require 'bundler'

Bundler.require

require './app.rb'

if ENV["RACK_ENV"] == "production"
  map '/nopaste' do
    run Sinatra::Application
  end
else 
  run Sinatra::Application
end
