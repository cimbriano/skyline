require './3_object_model/model.rb'
require './3_object_model/building.rb'

class Area < Model
  include Scadable

  attr_accessor :height, :width, :bldg_spacer, :stats

  # has_many
  attr_accessor :buildings

  def initialize(stats)
    @stats = stats
    @height = 10 # default
    @width = 10 # default
    @bldg_spacer = 5
    @max_height = 70
    @max_width = 140
  end

  def build

    num_of_buildings = stats['notes'].length
    total_notes = stats['song']['summary']['total_notes']

    stats['notes'].each do |note, note_hash| # number of buidlings to make

      puts "Making building for #{note}"

      building_height = note_hash['summary']['count']
      buidling_width  = note_hash['summary']['avgLen']

      # Mapping the percentage of this note to a range of 3 - 9
      building_depth  = (6 * (note_hash['summary']['count'] / total_notes)) + 3

      b = Building.new(buidling_width, building_height, building_depth)

      # puts "#{note_hash}"
      b.make_layers(note_hash)

      add_building(b)
    end
  end

  def scale
    # Get intial area size after all buildings have been created
    @width = required_area_width if @width < required_area_width
    @height = required_area_height

    aspect_ratio = @width.to_f / @height
    yscale_factor = @max_height / @height.to_f
    xscale_factor = @max_width / @width.to_f 

    #area is too high.  need to scale down
    #both are higher than max, use yscale_for both nuless its not enough for x
    if @height > @max_height and @width > @max_width
      # if scaling in the y is more severe than the x, just use the y
      if yscale_factor < xscale_factor
        xscale_factor = yscale_factor
      end
    #heights too high, but width doesn't care... 
    #scale down with y
    elsif @height > @max_height and @width <= @max_width
        xscale_factor = yscale_factor

    #too short and wide... scale up y and down x
    elsif @height <= @max_height and @width > @max_width
      # nothing here yet
    
    #too short and too narrow
    #scale up y and use that scale for x unless it's too much
    else
      if yscale_factor < xscale_factor
        xscale_factor = yscale_factor
      end
    end

    buildings.each do |b|
      b.scale(xscale_factor, yscale_factor)

  end


  def add_building(b)
    buildings << b

    # Check if width of all buildings (plus gutter space) exceeds the area width
    @width = required_area_width if @width < required_area_width
    @height = required_area_height
  end


  # TODO Need to take overlap into account
  def required_area_width
    sum = bldg_spacer

    buildings.each do |b|
      sum += (b.width + bldg_spacer)
    end

    sum
  end

  def required_area_height
    buildings.map {|b| b.height }.max + (2 * bldg_spacer)
  end

  def to_scad
    scad = []
    scad.tap do |s|
      s << "area(#{width}, #{height});"

      left_edge = bldg_spacer
      buildings.each do |b|
        s << "translate([#{left_edge}, 0, 0]) {"
        s << b.to_scad
        s << "}"

        left_edge += (b.width + bldg_spacer)
      end

    end
  end

  private

    def buildings
      @buildings ||= []
    end

end
