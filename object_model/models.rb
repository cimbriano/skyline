require './model.rb'

class Area < Model
  include Scadable

  attr_accessor :height, :width

  # has_many
  attr_accessor :buildings

  def initialize(w, h)
    @height = h
    @width = w
  end

  def buildings
    @buildings ||= []
  end

  def to_scad
    scad = []
    scad.tap do |s|
      s << "area(#{@width}, #{@height});"

      buildings.each do |b|
        s << b.to_scad
      end
    end
  end
end


class Building < Model
  attr_accessor :height, :width, :depth

  attr_accessor :left_edge

  # belongs_to (parent)
  attr_reader :area

  # has_many
  attr_accessor :windows

  # TODO Need a place to store the x, y, z translation

  def initialize(w, d, h)
    @height = h
    @width = w
    @depth = d
  end

  def windows
    @window ||= []
  end

  def to_scad
    scad = []
    scad.tap do |s|
      s << "building(#{@width}, #{@depth}, #{@height}, 0, 0, 0);"

      windows.each do |w|
        s << w.to_scad
      end
    end
  end
end


class Window < Model
  attr_accessor :height, :width

  attr_accessor :innie

  # belongs_to (parent)
  attr_reader :building

  # TODO Need a place to store the x, y, z translation

  def initialize(w, d, h, in_or_out)
    @height = h
    @width  = w
    @depth = d
    @innie = in_or_out
  end

  def innie?
    @innie
  end

  def outie?
    !@innie
  end

  def to_scad
    "window(#{@width}, #{@depth}, #{@height}, 0, 0, 0);"
  end
end
