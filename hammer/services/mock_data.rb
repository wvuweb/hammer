# encoding: utf-8
require 'erb'
require 'active_support/all'

class MockData
  
  def self.load(theme_root)
    if theme_root
      yml_path = theme_root.join(Pathname.new('mock_data.yml'))
      if yml_path.exist?
        erb = ERB.new(yml_path.read, nil, '-')
        data = erb.result(binding)
        yml = HashWithIndifferentAccess.new(YAML::load(data))
        
      else
        puts ' '
        puts 'WARNING:'.red
        puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'.black.on_red
        puts '!     Your theme does not include a mock_data.yml    !'.black.on_red
        puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'.black.on_red
        puts ' '
      end
    else
      puts ' '
      puts 'WARNING:'.red
      puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'.black.on_red
      puts '!       Your theme does not include a config.yml     !'.black.on_red
      puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'.black.on_red
      puts ' '
    end
  end
  
end