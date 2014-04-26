require 'optparse'
require './pipeline.rb'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: run.rb [options] <midi filename>"

  opts.on('-m', '--midi', "Read midi file and output notes file") do |m|
    options[:midi] = m
  end

  opts.on('-s', '--stats', "Read notes file and output stats file") do |s|
    options[:stats] = s
  end

  opts.on('-d', '--scad', "Read stats file and output scad file") do |d|
    options[:scad] = d
  end

end.parse!

# Set default options if none selected
options[:all] = true if options.empty?

puts "options: #{options}"
puts "ARGV filenames: #{ARGV.to_s}"

raise 'Provide a filename: ruby run.rb [options] <midi filename>' if ARGV.empty?

ARGV.each do |filename|

  # Run the piepline
  pipeline = Pipeline.new(filename)
  pipeline.run(options)
end
