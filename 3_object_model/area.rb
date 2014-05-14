require './3_object_model/model.rb'
require './3_object_model/building.rb'

class Area < Model
  include Scadable

  attr_accessor :height, :width, :bldg_x_spacer, :bldg_y_spacer, :stats

  # has_many
  attr_accessor :buildings

  def initialize(stats)
    @stats = stats
    @height = 10 # default
    @width = 10 # default
    @bldg_x_spacer = 5
    @bldg_y_spacer = 10
    @max_height = 70
    @max_width = 140
  end

  def build

    num_of_buildings = stats['notes'].length
    total_notes = stats['song']['summary']['total_notes']

    stats['notes'].each do |note, note_hash| # number of buidlings to make

      building_height = note_hash['summary']['count']
      buidling_width  = note_hash['summary']['avgLen']

      # Mapping the percentage of this note to a range of 3 - 9
      building_depth  = note_hash['summary']['totLenRank']/2 + 3

      b = Building.new(buidling_width, building_height, building_depth, note)

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

    @bldg_x_spacer *= xscale_factor
    @bldg_y_spacer *= yscale_factor

    @width *= xscale_factor
    @height *= yscale_factor

    buildings.each do |b|
      b.scale(xscale_factor, yscale_factor)
    end
  end


  def add_building(b)
    buildings << b

    # Check if width of all buildings (plus gutter space) exceeds the area width
    @width = required_area_width if @width < required_area_width
    @height = required_area_height
  end


  # TODO Need to take overlap into account
  def required_area_width
    sum = bldg_x_spacer

    buildings.each do |b|
      sum += (b.width + bldg_x_spacer)
    end

    sum
  end

  def required_area_height
    buildings.map {|b| b.height }.max + bldg_y_spacer
  end


  def add_post_scale_features
    buildings.each do |b|
      b.make_windows(stats['notes'][b.note])
      # b.do other stuff (i.e. b.add_trees, etc.)
    end
  end


  def to_scad
    scad = []
    scad.tap do |s|
      s << "area(#{width}, #{height});"

      buildings.sort! {|b1,b2| note_sorter(b1.note, b2.note)} 

      left_edge = bldg_x_spacer
      buildings.each do |b|
        puts "writing scad for building #{b.note}"
        s << "translate([#{left_edge}, 0, 0]) {"
        s << b.to_scad
        s << "}\n"

        left_edge += (b.width + bldg_x_spacer)
      end

    end
  end

  private

    def buildings
      @buildings ||= []
    end 

    def note_sorter(n1, n2)
      note_order = {
        "C" => 0,
        "C#" => 1,
        "D" => 2,
        "D#" => 3,
        "E" => 4,
        "F" => 5, 
        "F#" => 6, 
        "G" => 7, 
        "G#" => 8,
        "A" => 9,
        "A#" => 10,
        "B" => 11
      }
      note_order[n1] <=> note_order[n2]
    end

end
