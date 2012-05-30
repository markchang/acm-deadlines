require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'mongo'
require 'uri'
require 'date'

details = []

# mongo
@uri = URI.parse(ENV['MONGOLAB_URI'])
@conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
@db   = @conn.db(@uri.path.gsub(/^\//, ''))
@coll = @db['acm_deadlines']

# next 6 months
today = DateTime.now
this_month = DateTime.new(today.year, today.month)
(0..6).each do |d|
	the_date = this_month >> d
	date_string = the_date.strftime("%0m-%0d-%Y")

	puts "Fetching #{date_string}"

	doc = Nokogiri::HTML(open("http://campus.acm.org/public/cfpcal/event_listing.cfm?StartDate=#{date_string}&Reload=NO"))
	rows = doc.xpath('//table/tr')

	rows.each do |row|
		detail = {}
		detail[:date_string] = row.at_xpath('td[1]').content.strip
		detail[:date] = Date.parse("#{detail[:date_string]} #{the_date.year}").to_time
		detail[:link] = row.at_xpath('td[2]/a')['href']
		detail[:name] = row.at_xpath('td[2]/a').content.strip
		detail[:location] = row.at_xpath('td[2]/br').next.content.strip.gsub! /\n|\t|\r/,''

		# geocode
		geo_results = Geocoder.search(detail[:location])
		if not geo_results.empty?
			detail[:coordinates] = geo_results[0].coordinates
		else
			detail[:coordinates] = nil
		end

		if details.select { |deets| deets['link'] == detail[:link] }.empty?
			details << detail
			@coll.insert(detail)
		end
	end
end

puts details