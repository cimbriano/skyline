class Model
  def to_scad
    raise NotImplementedError, "Implement this method in the child class"
  end
end

module Scadable
  @@scad_libs = ['area.scad', 'building.scad', 'window.scad']

  def write_out_code
    header = []

    @@scad_libs.each do |lib|
      header << "use <../openscad/#{lib}>;"
    end

    header << "" # New line

    contents = header + to_scad

    File.write('out.scad', contents.join("\n"))
  end
end
