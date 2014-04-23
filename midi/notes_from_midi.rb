require './lib/midifile/midifile.rb'
require './note.rb'

if ARGV[0].nil?
  puts 'Usage: ruby test.rb <midi file to open>'
  exit 1
end

filename = ARGV[0]
note_buffer = {}

note_list = []

open(filename) do |f|
  mr = Midifile.new f

    mr.each do |item|

      if item.code == NOTE_ON then
        if note_buffer.include? item.data1 then
          raise "Found two consecutive ON for note: #{item.data1}"
        else
          note_buffer[item.data1] = item
        end

      elsif item.code == NOTE_OFF

        if note_buffer.include? item.data1 then
          # Create a Note
          n = Note.new(note_buffer[item.data1], item)

          # Append it to a list of Note
          note_list << n

          # Remove from Buffer
          note_buffer.delete(item.data1)
        else
          raise "Found an OFF without an ON for note: #{item.data1}"
        end
      end

      puts item.inspect
    end
end

# Write out meta info file
# TODO  Get this info from the meta items

# Write out notes file
contents = "letter,octave,velocity,time_on,time_off,duration" + "\n"
contents += note_list.map(&:to_csv).join("\n")

File.write('notes_file.csv', contents)
