class Pipeline
  def initialize(f)
    @filename = f
  end

  def run(opts)
    midi  if opts[:midi]  || opts[:all]
    stats if opts[:stats] || opts[:all]
    scad  if opts[:scad]  || opts[:all]
  end

  def midi
    puts "Doing midi stage for #{@filename}"
  end

  def stats
    puts "Doing stats stage for #{@filename}"
  end

  def scad
    puts "Doing scad stage for #{@filename}"
  end
end
