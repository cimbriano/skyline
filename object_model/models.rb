require './model.rb'

class Area < Model
  attr_accessor :height, :width
end

class Window < Model
end

class Building < Model
  attr_accessor :height, :width
end
