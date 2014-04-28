require './model.rb'
require './models.rb'



a = Area.new(50, 100)

(10..20).each do |x|
  b = Building.new(x, (x * 2), 3)

  # Default window parameters
  b.make_windows

  # TODO Resume here!
  puts "Building has #{b.windows.size} windows"

  a.add_building(b)
end

puts 'Writing code to out.scad'
a.write_out_code
