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

  end


  # TODO Need to take overlap into account
  def required_area_width
    sum = bldg_spacer

    buildings.each do |b|
      sum += (b.width + bldg_spacer)
    end

    sum
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
    num_layers = hash.length

    start_pos_y = 0 # First layer at y position = 0

    hash.each do |key, feature_hash|
      # width = ?
      layer_height = height / num_layers

      layers[key] = Layer.new(width, layer_height, depth, 0, start_pos_y, 0)

      start_pos_y += layer_height # Add last layer height to find start of next layer

    end
  end

  # def make_windows(opts = {})
  #   window_width = opts[:window_width] || 4
  #   window_height = opts[:window_height] || 4
  #
  #   puts "height: #{height}"
  #   puts "width : #{width}"
  #   puts "window_width : #{window_width}"
  #   puts "window_height : #{window_height}"
  #
  #   # How many windows fit
  #   num_windows_across = (width - (2 * border_x) + window_gutter_x) / (window_width + window_gutter_x)
  #   num_windows_down   = (height - (2 * border_y) + window_gutter_y) / (window_height + window_gutter_y)
  #
  #   puts "!Windows across : #{num_windows_across}"
  #   puts "!Windows down :   #{num_windows_down}"
  #
  #   # How much extra space for the left and right most edge gutter
  #   horizontal_used_space = (num_windows_across * window_width) + ((num_windows_across - 1) * window_gutter_x)
  #   puts "Horizontal Space used : #{horizontal_used_space}"
  #
  #   start_pos_x = ( (width  - horizontal_used_space).to_f ) / 2
  #   puts "start_pos_x : #{start_pos_x}"
  #
  #   # Bottom left corner of the top most window.
  #   top_window_y = height - border_y - window_height
  #   puts "top_window_y : #{top_window_y}"
  #
  #   horizontal_maximum = width - (border_x + window_width)
  #
  #   vertical_minimum = border_y + window_height
  #
  #   top_window_y.step(vertical_minimum, -(window_height + window_gutter_y)) do |y|
  #     puts "y : #{y}"
  #
  #     (start_pos_x..horizontal_maximum).step(window_width + window_gutter_x) do |x|
  #       puts "x : #{x}"
  #
  #       window_depth = 1
  #
  #       windows << Window.new(window_width, window_height, window_depth, x, y, depth - window_depth)
  #
  #     end
  #   end
  # end


  def to_scad
    scad = []
    scad.tap do |s|
      s << "union() {"

      layers.each do |l|
        s << l.to_scad
      end

      s << "}"
    end
  end

end

class Layer
  attr_accessor :height, :width, :depth

  attr_accessor :border_x, :border_y

  attr_accessor :window_gutter_x, :window_gutter_y

  attr_accessor :building_depth

  def initialize(x, y, building_depth, trans_x, trans_y, trans_z)
    @width = x
    @height = y

    @trans_x = trans_x
    @trans_y = trans_y
    @trans_z = trans_z

    # @depth = 1 # Thickness of layer groove

    @window_gutter_x = 1
    @window_gutter_y = 1

    @border_x = 1
    @border_y = 1

    @building_depth = building_depth

    make_windows
  end

  def windows
    @window ||= []
  end

  def make_windows(opts = {})
    window_width = opts[:window_width] || 4
    window_height = opts[:window_height] || 4

    puts "height: #{height}"
    puts "width : #{width}"
    puts "window_width : #{window_width}"
    puts "window_height : #{window_height}"

    # How many windows fit
    num_windows_across = (width - (2 * border_x) + window_gutter_x) / (window_width + window_gutter_x)
    num_windows_down   = (height - (2 * border_y) + window_gutter_y) / (window_height + window_gutter_y)

    puts "!Windows across : #{num_windows_across}"
    puts "!Windows down :   #{num_windows_down}"

    # How much extra space for the left and right most edge gutter
    horizontal_used_space = (num_windows_across * window_width) + ((num_windows_across - 1) * window_gutter_x)
    puts "Horizontal Space used : #{horizontal_used_space}"

    start_pos_x = ( (width  - horizontal_used_space).to_f ) / 2
    puts "start_pos_x : #{start_pos_x}"

    # Bottom left corner of the top most window.
    top_window_y = height - border_y - window_height
    puts "top_window_y : #{top_window_y}"

    horizontal_maximum = width - (border_x + window_width)

    vertical_minimum = border_y + window_height

    top_window_y.step(vertical_minimum, -(window_height + window_gutter_y)) do |y|
      puts "y : #{y}"

      window_y_trans = y + @trans_y # Windiow's relative position (y) plus the layer's translation (trans_y)

      (start_pos_x..horizontal_maximum).step(window_width + window_gutter_x) do |x|
        puts "x : #{x}"

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

  # def trans_z
  #   building_depth - 1
  # end



        # s << "difference() {"
        #   s << "union() {"
        #
        #
        #     s << "layer();"
        #     s << "building(#{@width}, #{@height}, #{@depth});"
        #
        #     outie_windows.each do |outie|
        #       s << outie.to_scad
        #     end
        #
        #     s << "}" # Closes Union
        #
        #   innie_windows.each do |innie|
        #     s << innie.to_scad
        #   end
        #
        #   first_layer, *tail_layers = layers
        #   tail_layers.each do |l|
        #     s << l.to_scad
        #   end
        #
        # s << "}" # Closes Difference


  def to_scad
    scad = []

    scad.tap do |s|
      s << "difference(){"

        s << "union(){"

          s << "layer(#{width}, #{height}, #{building_depth}, #{@trans_x}, #{@trans_y}, #{@trans_z});"

          innie_windows.each do |innie|
            s << innie.to_scad
          end

        s << "}" # Closes union

        outie_windows.each do |outie|
          s << outie.to_scad
        end

      s << "}" # Closes difference
    end


    # "layer_(#{width}, #{1}, #{depth}, #{0}, #{height}, #{trans_z});"
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
