require './lib/midifile/midifile.rb'

if ARGV[0].nil?
  puts 'Usage: ruby test.rb <midi file to open>'
  exit 1
end

filename = ARGV[0]

open(filename) do |f|
  mr = Midifile.new f

    mr.each do |ev|
        puts ev
    end
end
