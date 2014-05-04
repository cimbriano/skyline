require './model.rb'
require './models.rb'

require 'json'

features_from_file = {}

File.open('features.json') do |f|
  features_from_file = JSON.load(f)
end

puts features_from_file


features = {
  building_height: 22,
  building_width: 11,
  layers_per_building: 2
}


a = Area.new(10, 50)

# (10..20).each do |x|
(20..21).each do |x|
  b = Building.new(x, (x * 2), 3)

  # Default window parameters
  b.make_layers(features[:layers_per_building])

  a.add_building(b)
end

puts 'Writing code to out.scad'
a.write_out_code
