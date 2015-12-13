require './1_midi/lib/midifile/midifile.rb'
require './1_midi/note.rb'
require './1_midi/nqueue.rb'

module MIDI
  def make_note_list_from_midi_file(midifile)

    note_buffer = {}
    note_list = []

    open(midifile) do |f|
      mr = Midifile.new f

        notequeue = NoteQueue.new

        mr.each do |item|

          if item.code == NOTE_ON and item.data2 != 0 then
            notequeue.enqueue(item)
          elsif item.code == NOTE_OFF or (item.code == NOTE_ON and item.data2 == 0) then
            on = notequeue.dequeue(item)

            if on.nil? then
              puts "Found an OFF without an ON for note: #{item.data1}"
            else
              n = Note.new(on, item)

              note_list << n
            end

          end

          # if item.code == NOTE_ON and item.data2 != 0 then
          #   if note_buffer.include? item.data1 then

          #     # This might be a velocity 0 note (that's ok)

          #     # Otherwise error
          #     puts note_buffer[item.data1]
          #     puts item
          #     raise "Found two consecutive ON for note: #{item.data1}"
          #   else

          #     note_buffer[item.data1] = item  
          #   end

          # elsif item.code == NOTE_OFF or (item.code == NOTE_ON and item.data2 == 0)

          #   if note_buffer.include? item.data1 then
          #     # Create a Note
          #     n = Note.new(note_buffer[item.data1], item)

          #     # Append it to a list of Note
          #     note_list << n

          #     # Remove from Buffer
          #     note_buffer.delete(item.data1)
          #   else
          #     puts item
          #     raise "Found an OFF without an ON for note: #{item.data1}"
          #   end
          # end

          # puts item.inspect
        end
    end

    note_list
  end
end
