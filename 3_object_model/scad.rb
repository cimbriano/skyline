module SCAD

  def default_features
    {
      building_height: 22,
      building_width: 11,
      layers_per_building: 2
    }
  end

  def get_stats_hash(stats_file)
    f = File.open(stats_file)
    stats_hash = JSON.load(f)
  end

  def make_model_from_stats_hash(stats)

    puts stats

    num_of_buildings = stats['notes'].length
    total_notes = stats['song']['summary']['total_notes']


    main_area = Area.new(10, 50)

    stats['notes'].each do |note, note_hash| # number of buidlings to make

      puts "Making building for #{note}"

      building_height = note_hash['summary']['count']
      buidling_width  = note_hash['summary']['avgLen']

      # Mapping the percentage of this note to a range of 3 - 9
      building_depth  = (6 * (note_hash['summary']['count'] / total_notes)) + 3

      b = Building.new(buidling_width, building_height, building_depth)

      # puts "#{note_hash}"
      b.make_layers(note_hash['octaves'])

      main_area.add_building(b)
    end

    main_area
  end



  #
  # def make_area_from_features(features)
  #   main_area = Area.new(10, 50)
  #
  #   # (10..20).each do |x|
  #   (20..21).each do |x|
  #
  #
  #     b = Building.new(x, (x * 2), 3 * (x % 19))
  #
  #     # Default window parameters
  #     b.make_layers(features[:layers_per_building])
  #
  #     main_area.add_building(b)
  #   end
  #
  #   main_area
  # end

end
