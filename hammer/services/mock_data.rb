# encoding: utf-8
require 'erb'
require 'active_support/all'

module YAML
  @@file_root = ''
  def self.set_file_root(x)
    @@file_root = x
  end

  def YAML.include file_name
    require 'erb'
    yml_path =  @@file_root.join(Pathname.new('data/'+file_name))

    if yml_path.exist?
      erb = ERB.new(yml_path.read, nil, '-')
      erb.result(binding)
    else
      puts ' '
      puts 'WARNING:'.red
      puts '!'.black.on_red * (44 + file_name.length)
      puts '!    Your theme does not include a '.black.on_red+file_name.black.on_red+' file   !'.black.on_red
      puts '!'.black.on_red * (44 + file_name.length)
      puts ' '
    end
  end
end


class MockData

  def self.load(theme_root, request_path)
    @request_path = request_path

    YAML.set_file_root(theme_root)

    if theme_root
      yml_path = theme_root.join(Pathname.new('mock_data.yml'))
      if yml_path.exist?
        erb = ERB.new(yml_path.read, nil, '-')
        data = erb.result(binding)
        yml = HashWithIndifferentAccess.new(YAML::load(data))

        template_yml_name = theme_root.join(File.basename(request_path, ".html").to_s+'.yml')
        template_yml_path = theme_root.join(Pathname.new(template_yml_name))
        if template_yml_path.exist?
          template_erb = ERB.new(template_yml_path.read, nil, '-')
          template_data = template_erb.result(binding)
          template_yml = HashWithIndifferentAccess.new(YAML::load(template_data))
          yml = yml.deep_merge template_yml
        end

        yml
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
