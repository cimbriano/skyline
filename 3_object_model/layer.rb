require './3_object_model/model.rb'
require './3_object_model/window.rb'

class Layer < Model
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

  def make_windows(x_density, y_density)
    #make windows here\
  end


  def make_windows_old(opts = {})
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

  def scale(xscale, yscale)
    @height *= yscale
    @width *= xscale
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
