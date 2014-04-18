require './lib/midifile/midifile.rb'

filename = ARGV[0]

open(filename) do |f|
  mr = Midifile.new f

    mr.each do |ev|
        puts ev
    end
end
