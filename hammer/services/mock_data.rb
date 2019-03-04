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
      # puts ' '
      # puts 'WARNING:'.red
      # puts '!'.black.on_red * (44 + file_name.length)
      # puts '!    Your theme does not include a '.black.on_red+file_name.black.on_red+' file   !'.black.on_red
      # puts '!'.black.on_red * (44 + file_name.length)
      # puts ' '
      Hammer.error "Your theme does not include a #{yml_path}"
    end
  end
end


class MockData

  def self.load(theme_root, request_path)
    result = {}
    result[:yml] = nil
    result[:errors] = []
    @request_path = request_path

    YAML.set_file_root(theme_root)

    if theme_root
      yml_path = theme_root.join(Pathname.new('mock_data.yml'))
      if yml_path.exist?
        erb = ERB.new(yml_path.read, nil, '-')
        data = erb.result(binding)
        yml = HashWithIndifferentAccess.new(YAML::load(data))

        template_yml_name = File.basename(request_path, ".html")+".yml"
        template_yml_path = theme_root.join('data',Pathname.new(template_yml_name))
        old_template_yml_path = theme_root.join(Pathname.new(template_yml_name))

        if template_yml_path.exist?
          template_erb = ERB.new(template_yml_path.read, nil, '-')
          template_data = template_erb.result(binding)
          template_yml = HashWithIndifferentAccess.new(YAML::load(template_data))
          yml = yml.deep_merge template_yml
        elsif old_template_yml_path.exist?
          result[:errors] << (Hammer.error "Depreciation notice: #{old_template_yml_path} needs to be moved to the /data folder", {warning: true})
        end
      else
        yml_path = Pathname.new(File.expand_path File.dirname('..')+'/data/mock_data.yml')
        erb = ERB.new(yml_path.read, nil, '-')
        data = erb.result(binding)
        yml = HashWithIndifferentAccess.new(YAML::load(data))
        result[:errors] << (Hammer.error "Your theme does not include a mock_data.yml")
      end
      result[:yml] = yml
    else
      result[:errors] << (Hammer.error "Your theme does not include a config.yml")
    end
    result

  end


end
