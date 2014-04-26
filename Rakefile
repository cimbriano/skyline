task :default => :build

desc 'Given midi file, runs it through the pipeline'
task :build do
  puts 'Starting pipeline...'
  Rake::Task['output_scad'].invoke
end

desc 'Given midi file, makes note file'
task :raw_midi do |t|
  puts "Doing #{t}"
end

desc 'Given note file, outputs stats file'
task :calc_stats => [:raw_midi] do |t|
  puts "Doing #{t}"
end

desc 'Given stats file, outputs ...?'
task :build_object_model => [:calc_stats] do |t|
  puts "Doing #{t}"
end

desc 'Given ...?, outputs SCAD file'
task :output_scad => [:build_object_model] do |t|
  puts "Doing #{t}"
end
