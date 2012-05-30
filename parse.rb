require 'nokogiri'
require 'open-uri'

details = []

# next 6 months
(0..2).each do |d|
	the_date = Date.today >> d
	date_string = the_date.strftime("%0m-%0d-%Y")
	doc = Nokogiri::HTML(open("http://campus.acm.org/public/cfpcal/event_listing.cfm?StartDate=#{date_string}&Reload=NO"))
	rows = doc.xpath('//table/tr')

	rows.each do |row|
		detail = {}
		detail[:date_string] = row.at_xpath('td[1]').content.strip
		detail[:date] = Date.parse("#{detail[:date_string]} #{the_date.year}")
		detail[:link] = row.at_xpath('td[2]/a')['href']
		detail[:name] = row.at_xpath('td[2]/a').content.strip
		detail[:location] = row.at_xpath('td[2]/br').next.content.strip.gsub! /\n|\t|\r/,''

		if details.select { |deets| deets['link'] == detail[:link] }.empty?
			details << detail
		end
	end
end

puts details