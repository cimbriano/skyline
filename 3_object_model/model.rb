class Model
  def to_scad
    raise NotImplementedError, "Implement this method in the child class: #{caller[0]}"
  end
end

module Scadable
  @@scad_libs = ['area.scad', 'building.scad', 'layer_divider.scad', 'window.scad']

  def write_out_code
    header = []

    @@scad_libs.each do |lib|
      header << "use <../4_openscad/#{lib}>;"
    end

    header << "" # New line

    contents = header + to_scad

    File.write('out.scad', contents.join("\n"))
  end
end
