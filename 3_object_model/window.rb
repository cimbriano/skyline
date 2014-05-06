require './3_object_model/model.rb'

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
