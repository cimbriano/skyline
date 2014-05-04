module SCAD

  def default_features
    {
      building_height: 22,
      building_width: 11,
      layers_per_building: 2
    }
  end

  def get_features(stats_file)
    f = File.open(stats_file)
    features = JSON.load(f)
    features.merge(default_features)
  end

  def make_area_from_features(features)
    main_area = Area.new(10, 50)

    # (10..20).each do |x|
    (20..21).each do |x|
      b = Building.new(x, (x * 2), 3)

      # Default window parameters
      b.make_layers(features[:layers_per_building])

      main_area.add_building(b)
    end

    main_area
  end

end
