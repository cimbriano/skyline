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

    yscale_factor = tgt_height / @height.to_f
    xscale_factor = tgt_width / @width.to_f

    puts "height: #{height}"
    puts "width: #{width}"
    puts "orig aspect_ratio: #{aspect_ratio}"
    puts "xscale: #{xscale_factor}"
    puts "yscale: #{yscale_factor}"


    if shape == 'square'
      puts "SQUARE"
      if xscale_factor < yscale_factor
        yscale_factor = xscale_factor
      else
        xscale_factor = yscale_factor
      end
      puts "xscale: #{xscale_factor}"
      puts "yscale: #{yscale_factor}"


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

  def aspect_ratio
    width.to_f / height
  end

  def shape
    if aspect_ratio < 0.7
      'vertical'
    elsif aspect_ratio >= 0.7 and aspect_ratio < 1.3
      'square'
    else
      'horizontal'
    end
  end

  def tgt_height
    case shape
    when 'vertical'
      140
    when 'square'
      100
    when 'horizontal'
      70
    end
  end


  def tgt_width
    case shape
    when 'vertical'
      70
    when 'square'
      100
    when 'horizontal'
      140
    end
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

      # Add the connecting base to all the buildings
      base_z = buildings.map {|b| b.depth }.max
      s << "base(#{width}, #{1}, #{base_z}, #{0}, #{-1}, #{0});"

      # Sort the buildings in Note order (C, C#, D, D# ... )
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
