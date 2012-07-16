# -*- coding: utf-8 -*-

require 'rubygems'

require 'yaml'
require 'hashie'
require 'sinatra'
require 'sinatra/activerecord'
require 'rack/csrf'

def load_config
    Hashie::Mash.new(YAML.load_file("./config/config.yml"))
rescue
    raise "there is nothing \"/config/config.yml\""
end

configure :development, :test do
  require 'pry'
  set :database, "sqlite:///db/development.db"
end

configure :production do
  set :database, "sqlite:///../../shared/db/production.db"
end

configure do
  set :public_folder, File.dirname(__FILE__) + '/public'
  config = load_config()
  use Rack::Session::Cookie, :secret => config.app.session_secret
  use Rack::Csrf, :raise => true
  set :protection, :except => :json_csrf
end

ActiveRecord::Base.logger = Logger.new("./database.log")

class Post < ActiveRecord::Base
  attr_accessible :username, :title, :body
  validates :body, :presence => { :message => "は必須です." }
  validates_length_of :username, :maximum => 10, :too_long => "は10文字までです."
  validates_length_of :title, :maximum => 100, :too_long => "は100文字までです."
  validates_length_of :body, :maximum => 30000, :too_long => "は30,000文字までです."
end

helpers do
  def root(str)
    "/nopaste#{str}"
  end
  def h(str)
    CGI.escapeHTML str.to_s
  end

  def csrf_token
    Rack::Csrf.csrf_token(env)
  end

  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end
end

get '/' do
  erb :index
end

get '/:id' do
  @post = Post.find(convert62to10 params[:id])
  erb :show
end

post '/' do
  begin
    post = Post.create!(username: params[:username], title: params[:title], body: params[:body])
    redirect root("/#{convert10to62 post.id}")
  rescue ActiveRecord::RecordInvalid => e
    @err_msg = e.message
    @post = e.record
    erb :index
  end
end

private

def n_map
  n_map = { 1=>"W", 2=>"A", 3=>"n", 4=>"7", 5=>"a", 6=>"9",
            7=>"D", 8=>"B", 9=>"p", 10=>"0", 11=>"o", 12=>"5",
            13=>"1", 14=>"O", 15=>"r", 16=>"S", 17=>"I", 18=>"2",
            19=>"q", 20=>"Q", 21=>"K", 22=>"u", 23=>"f", 24=>"P",
            25=>"e", 26=>"6", 27=>"s", 28=>"8", 29=>"b", 30=>"Y",
            31=>"N", 32=>"h", 33=>"H", 34=>"l", 35=>"y", 36=>"z",
            37=>"U", 38=>"R", 39=>"t", 40=>"c", 41=>"E", 42=>"G",
            43=>"Z", 44=>"j", 45=>"T", 46=>"m", 47=>"3", 48=>"L",
            49=>"M", 50=>"k", 51=>"x", 52=>"J", 53=>"g", 54=>"d",
            55=>"C", 56=>"F", 57=>"i", 58=>"v", 59=>"w", 60=>"X",
            61=>"4", 62=>"V" }
end

def convert10to62(i)
  digit = []
  begin
    i, c = i.divmod(62)
    digit << n_map[c+1]
  end while i > 0
  return digit.reverse.join('')
end

def convert62to10(s64)
  n_map_inverted = n_map.invert
  c = 0
  digit = 0
  s64.each_char { |s|
    c += 1
    digit += (n_map_inverted[s] - 1) * (62**(s64.length - c))
  }
  digit
end
