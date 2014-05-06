require 'fileutils'
require 'json'
require 'debugger'

require './1_midi/lib/midifile/midifile.rb'
require './1_midi/note.rb'

require './3_object_model/model.rb'
require './3_object_model/models.rb'
require './3_object_model/midi.rb'
require './3_object_model/scad.rb'



class Pipeline
  include MIDI
  include SCAD

  def initialize(path_to_src)
    @src_path = path_to_src
  end

  def run(opts)
    sanity_check
    setup
    midi  if opts[:midi]  || opts[:all]
    stats if opts[:stats] || opts[:all]
    scad  if opts[:scad]  || opts[:all]
  end

  private
    def sanity_check
      puts "=========="
      puts "src_path is: #{@src_path}"
      puts "out_dir is: #{out_dir}"
      puts "midi file is: #{midi_file}"
      puts "notes file is: #{notes_file}"
      puts "stats file is: #{stats_file}"
      puts "scad file is: #{scad_file}"
    end

    def setup
      # Make sure out directory exists
      FileUtils::mkdir_p out_dir
    end

    def midi
      puts "=========="
      puts "Doing midi stage for #{@src_path}"
      puts "Reading: #{midi_file}"

      note_list = make_note_list_from_midi_file(midi_file)

      # Write out meta info file
      # TODO  Get this info from the meta items

      # Write out notes file
      contents = "letter,octave,velocity,time_on,time_off,duration,note_number" + "\n"
      contents += note_list.map(&:to_csv).join("\n")

      puts "Writing notes file: #{notes_file}"
      File.write(notes_file, contents)
    end

    def midi_file
      @src_path
    end

    def notes_file
      "#{out_dir}/notes_#{basename}.csv"
    end

    # STATS Section

    def stats
      puts "=========="
      puts "Doing stats stage for #{@src_path}"

      options = ""

      # This python script reads from notes_files and writes to stats_file
      result = `python #{options} ./2_stats/stats.py #{notes_file} #{stats_file}`
      puts result
    end

    def stats_file
      "#{out_dir}/stats_#{basename}.json"
    end

    # SCAD Section

    def scad
      puts "=========="
      puts "Doing scad stage for #{@src_path}"
      stats_hash = get_stats_hash(stats_file)

      model = make_model_from_stats_hash(stats_hash)

      model.write_out_code(scad_file)
    end

    def scad_file
      "#{out_dir}/scad_#{basename}.scad"
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
