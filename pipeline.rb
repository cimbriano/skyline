require 'fileutils'

require './1_midi/lib/midifile/midifile.rb'
require './1_midi/note.rb'

require './3_object_model/model.rb'
require './3_object_model/models.rb'


class Pipeline


  def initialize(path_to_src)
    @src_path = path_to_src
  end

  def run(opts)
    setup
    midi  if opts[:midi]  || opts[:all]
    stats if opts[:stats] || opts[:all]
    scad  if opts[:scad]  || opts[:all]
  end

  private
    def setup
      # Make sure out directory exists
      FileUtils::mkdir_p out_dir
    end

    def midi
      puts "Doing midi stage for #{@src_path}"
      puts "Reading: #{midi_file}"

      note_list = make_note_list_from_midi_file(midi_file)

      # Write out meta info file
      # TODO  Get this info from the meta items

      # Write out notes file
      contents = "letter,octave,velocity,time_on,time_off,duration" + "\n"
      contents += note_list.map(&:to_csv).join("\n")

      puts "Writing notes file: #{notes_file}"
      File.write(notes_file, contents)
    end


    def make_note_list_from_midi_file(src_path)
      note_buffer = {}
      note_list = []

      open(src_path) do |f|
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

    def midi_file
      @src_path
    end

    def notes_file
      "#{out_dir}/notes_file_#{basename}.csv"
    end

    # STATS Section

    def stats
      puts "Doing stats stage for #{@filename}"
      notes_file = "#{out_dir}/notes_file_#{basename}.csv"

      #
    end

    def stats_file
      "#{out_dir}/stats_#{basename}"
    end

    # SCAD Section

    def scad
      puts "Doing scad stage for #{@filename}"
    end

    def scad_file
      "#{out_dir}/scad_#{basename}"
    end



    # MISC Helpers

    def out_dir
      @out ||= "./out/#{basename}"
    end

    # Returns the filename withouth the extension
    def basename
      @basename ||= File.basename(@src_path, '.*')
    end

    # Returns the filename including the extension
    def filename
      @filename ||= File.basename(@src_path)
    end
end
