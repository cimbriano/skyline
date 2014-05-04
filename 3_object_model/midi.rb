module MIDI
  def make_note_list_from_midi_file(midifile)

    note_buffer = {}
    note_list = []

    open(midifile) do |f|
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

    note_list
  end
end
