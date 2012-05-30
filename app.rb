require 'rubygems'
require 'mongo'
require 'sinatra'
require 'uri'
require 'json'

require "sinatra/reloader" if development?

set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
	erb :index
end

get '/list' do
	@uri = URI.parse(ENV['MONGOLAB_URI'])
	@conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
	@db   = @conn.db(@uri.path.gsub(/^\//, ''))
	@coll = @db['acm_deadlines']

	@conferences = []

	# find everything
	@coll.find.each do |conference|
		@conferences << conference
	end

	erb :list, :locals => {:conferences => @conferences}
end

get '/data' do
	content_type :json

	@uri = URI.parse(ENV['MONGOLAB_URI'])
	@conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
	@db   = @conn.db(@uri.path.gsub(/^\//, ''))
	@coll = @db['acm_deadlines']

	markers = []

	# find everything
	@coll.find.each do |marker|
		markers << marker
	end

	# to_json
	return_hash = {:markers => markers}
	return_hash.to_json
end
