require 'data_mapper'
require 'json'
require 'yaml'
require 'pry'
Dir.glob("models/*.rb").each {|x| require_relative x}

def import_model(model_class)
  infile = File.new("dumped_#{model_class.to_s.downcase}.json")
  json_data = JSON.parse(infile.read)
  json_data.each do |row|
    model_class.create(row)
  end
end

def dump_model(model_class)
  collector = []
  model_class.all.each do |m|
    collector << JSON.parse(m.to_json)
  end
  outfile = File.new("dumped_#{model_class.to_s.downcase}.json", "w")
  outfile.write(collector.to_json)
end

def import
  DataMapper.auto_migrate!
  import_model(Monster)
  import_model(User)
end

def export
  dump_model(User)
  dump_model(Monster)
end

def console
  binding.pry
end

def print_usage
  puts "USAGE: ruby db_utils.rb [IMPORT|EXPORT|CONSOLE]"
end

config = YAML.load(File.read("database_config.yaml"))
DataMapper.setup(:default, config)
DataMapper.finalize
command = ARGV.first
if command.nil?
  print_usage
else
  case command
    when 'import'
      import
    when 'export'
      export
    when 'console'
      console
    else
      print_usage
  end
end
