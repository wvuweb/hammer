# encoding: utf-8
require 'erb'
require 'active_support/all'


class MockData

  def self.load(theme_root, request_path)
    @request_path = request_path
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
