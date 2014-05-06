require './3_object_model/model.rb'

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
