require './models.rb'

a = Area.new(200, 100)

b = Building.new(20, 40, 3)

b.windows << Window.new(4, 4, 2, true)

a.buildings << b

puts 'Writing code to out.scad'
a.write_out_code
