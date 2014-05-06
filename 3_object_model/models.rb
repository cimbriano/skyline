class Area < Model
  include Scadable

  attr_accessor :height, :width, :bldg_spacer

  # has_many
  attr_accessor :buildings

  def initialize(w, h)
    @height = h
    @width = w
    @bldg_spacer = 5
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


class Building < Model
  attr_accessor :height, :width, :depth

  attr_accessor :left_edge

  # :window_gutter_x, :window_gutter_y, :border_x, :border_y

  # belongs_to (parent)
  attr_reader :area

  # has_many
  # attr_accessor :windows

  attr_accessor :layers

  # TODO Need a place to store the x, y, z translation

  def initialize(x, y, z)
    @width = x
    @height = y
    @depth = z

    # @window_gutter_x = 1
    # @window_gutter_y = 1
    #
    # @border_x = 1
    # @border_y = 1
  end

  def layers
    @layers ||= {}
  end

  # hash has keys for each layer for this building.
  def make_layers(hash)


    num_layers = hash['octaves'].length # octaves hash for now

    puts "Making #{num_layers} layers"

    hash['octaves'].each do |key, octave_hash|

      layer_height = height * (octave_hash['totLen'] / hash['summary']['totLen'])

      layers[key] = Layer.new(width, layer_height, depth)
    end
  end

  def to_scad
    layer_dividers = []


    scad = []
    scad.tap do |s|

        s << "union() {"

        layer_start_y_pos = 0 # First layer at y position = 0

        layers.each do |key, layer|

          s << "layer_divider(#{width}, #{1}, #{1}, #{0}, #{layer_start_y_pos}, #{depth});"
          s << layer.to_scad(layer_start_y_pos)


          layer_start_y_pos += layer.height
        end

        s << "}" # Closes union

    end

  end

end

class Layer
  attr_accessor :height, :width, :depth

  attr_accessor :border_x, :border_y

  attr_accessor :window_gutter_x, :window_gutter_y

  attr_accessor :building_depth

  def initialize(x, y, building_depth)
    @width = x
    @height = y

    @window_gutter_x = 1
    @window_gutter_y = 1

    @border_x = 1
    @border_y = 1

    @building_depth = building_depth

    # make_windows
  end

  def windows
    @window ||= []
  end

  def make_windows(opts = {})
    window_width = opts[:window_width] || 4
    window_height = opts[:window_height] || 4


    # puts "height: #{height}"
    # puts "width : #{width}"
    # puts "window_width : #{window_width}"
    # puts "window_height : #{window_height}"

    # How many windows fit
    num_windows_across = (width - (2 * border_x) + window_gutter_x) / (window_width + window_gutter_x)
    num_windows_down   = (height - (2 * border_y) + window_gutter_y) / (window_height + window_gutter_y)

    # puts "!Windows across : #{num_windows_across}"
    # puts "!Windows down :   #{num_windows_down}"

    # How much extra space for the left and right most edge gutter
    horizontal_used_space = (num_windows_across * window_width) + ((num_windows_across - 1) * window_gutter_x)
    # puts "Horizontal Space used : #{horizontal_used_space}"

    start_pos_x = ( (width  - horizontal_used_space).to_f ) / 2
    # puts "start_pos_x : #{start_pos_x}"

    # Bottom left corner of the top most window.
    top_window_y = height - border_y - window_height
    # puts "top_window_y : #{top_window_y}"

    horizontal_maximum = width - (border_x + window_width)

    vertical_minimum = border_y + window_height

    top_window_y.step(vertical_minimum, -(window_height + window_gutter_y)) do |y|
      # puts "y : #{y}"

      window_y_trans = y + @trans_y # Windiow's relative position (y) plus the layer's translation (trans_y)

      (start_pos_x..horizontal_maximum).step(window_width + window_gutter_x) do |x|
        # puts "x : #{x}"

        window_depth = 1

        in_or_out = [true, false].sample

        windows << Window.new(window_width, window_height, window_depth, x, window_y_trans, building_depth - window_depth, in_or_out)

      end
    end
  end

  def innie_windows
    windows.select {|w| w.innie?}
  end

  def outie_windows
    windows.select {|w| w.outie?}
  end

  def to_scad(trans_y)
    scad = []

    scad.tap do |s|
      s << "difference(){"

        s << "union(){"

          s << "layer(#{width}, #{height}, #{building_depth}, 0, #{trans_y}, 0);"

          innie_windows.each do |innie|
            s << innie.to_scad
          end

        s << "}" # Closes union

        outie_windows.each do |outie|
          s << outie.to_scad
        end

      s << "}" # Closes difference
    end
  end
end


class Window < Model
  attr_accessor :height, :width

  attr_accessor :innie

  # belongs_to (parent)
  attr_reader :building

  # TODO Need a place to store the x, y, z translation

  def initialize(x, y, z, trans_x, trans_y, trans_z, in_or_out=true)
    @width  = x
    @height = y
    @depth = z

    @trans_x = trans_x
    @trans_y = trans_y
    @trans_z = trans_z

    @innie = in_or_out
  end

  def innie?
    @innie
  end

  def outie?
    !@innie
  end

  def thickness
    @depth * 2
  end

  def to_scad
    "window(#{@width}, #{@height}, #{thickness}, #{@trans_x}, #{@trans_y}, #{@trans_z});"
  end
end
