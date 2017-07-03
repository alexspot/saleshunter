require 'nokogiri'
require 'byebug'


file = Nokogiri::HTML(File.open('farfetch_dump.html'))
model_name = []
model = file.css('.listing-item-content-description')
model.each do |item|
  model_name << item.text
end



byebug

sleep 10



