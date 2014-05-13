require './3_object_model/model.rb'
require './3_object_model/window.rb'

class Layer < Model
  attr_accessor :height, :width, :depth

  attr_accessor :window_gutter_x, :window_gutter_y

  attr_accessor :window_height, :window_width, :window_depth

  attr_accessor :building_depth

  def initialize(x, y, building_depth)
    @width = x
    @height = y

    @window_gutter_x = 0.5
    @window_gutter_y = 0.5

    @window_height = 2
    @window_width = 1
    @window_depth = 0.5

    @building_depth = building_depth

    # make_windows
  end

  def windows
    @window ||= []
  end

  def make_windows(x_density, y_density)
    num_windows_across = (x_density * max_windows_x).to_int
    num_windows_down = (y_density * max_windows_y).to_int

    actual_gutter_y = (height - (num_windows_down * window_height)) / (num_windows_down + 1)
    actual_gutter_x = (width - (num_windows_across + window_width)) / (num_windows_across + 1)

    for y_index in 1..num_windows_down 
      for x_index in 1..num_windows_across 
        in_or_out = [true, false].sample
        
        ytrans = y_index * actual_gutter_y + (y_index - 1)*window_height
        xtrans = x_index * actual_gutter_x + (x_index - 1)*window_width

        windows << Window.new(window_width, window_height, window_depth, xtrans, ytrans, building_depth - window_depth, in_or_out)
      end
    end
  end

  def max_windows_x
    ( ( width - window_gutter_x ) / (window_width + window_gutter_x) ).to_int
  end

  def max_windows_y
    ( ( height - window_gutter_y ) / (window_height + window_gutter_y) ).to_int
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
