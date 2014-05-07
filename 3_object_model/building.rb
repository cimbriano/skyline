require './3_object_model/model.rb'
require './3_object_model/layer.rb'

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

  def scale(xscale, yscale)
    @width *= xscale
    @height *= yscale

    layers.each do |l|
      l.scale(xscale, yscale)

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
