# encoding: utf-8

class MockData
  
  def self.load(theme)
    
    basename = 'mock_data.yml'
    yml = File.join(theme, basename)
    if File.exists?(yml)    
      file = File.open(yml)
      erb = ERB.new(file.read, nil, '-')
      file.close
      yml_data = erb.result(binding)
      YAML::load(yml_data)
    else
      puts ' '
      puts 'WARNING:'.red
      puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'.black.on_red
      puts '!     Your theme does not include a mock_data.yml    !'.black.on_red
      puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'.black.on_red
      puts ' '
      
      false
    end
    
  end
  
end