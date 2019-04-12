# encoding: utf-8
require 'erb'
require 'active_support/all'

class YamlIncludeError < StandardError
end

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
      raise YamlIncludeError, "You are trying to include a yml partial in your mock_data.yml file that is not included in your theme: #{yml_path}.  Please create the file or delete the include."
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

    # # Deep Merging of yml files using map reduce
    # yml_files = []
    # # Load default mock data
    # yml << Pathname.new(File.dirname(__FILE__)+'/../data/mock_data.yml')
    #
    # # Load Theme Root mock_data.yml
    # theme_root_yml = theme_root.join(Pathname.new('mock_data.yml'))
    # if theme_root_yml
    #   yml_files << theme_root_yml
    # end
    #
    # # Load Template YAML files
    # template_yml = theme_root.join('data',Pathname.new(File.basename(request_path, ".html")+".yml"))
    # old_path_template_yml =  theme_root.join(Pathname.new(File.basename(request_path, ".html")+".yml"))
    # if template_yml.exist?
    #   yml_files << template_yml
    # elseif old_path_template_yml.exist?
    #   yml_files << old_path_template_yml
    # end
    # TODO: Parse new yml
    # combined_yml = yml_files.map{ |file| YAML.load_file(file) }.reduce( {}, :deep_merge!)
    # TODO: Erb parse new combined YML

    if theme_root
      yml_path = theme_root.join(Pathname.new('mock_data.yml'))
      if yml_path.exist?
        erb = ERB.new(yml_path.read, nil, '-')
        data = erb.result(binding)
        begin
          yml = HashWithIndifferentAccess.new(YAML::load(data))
        rescue Psych::SyntaxError => e
          line_message = e.message.to_s
          if line_message.include?("at line")
            line_message = line_message.partition('at line')[-2] + line_message.partition('at line')[-1]
          end
          raise YamlIncludeError, "There is an error in your mock_data.yml file #{line_message} (line # includes any included partial YAML files)"
        end
        # Check for older shared_themes syntax
        if !yml['shared_themes'].nil? && yml['shared_themes'].first[1].class == HashWithIndifferentAccess
          result[:errors] << (Hammer.error "The mock data syntax you are using for <code>shared_themes:</code> is being depreciated, please see <a href='https://github.com/wvuweb/hammer/wiki/Mock-Data#shared-themes-syntax'>Shared Theme Syntax in the Hammer wiki</a> for more information.", {depreciation: true})
        end

        template_yml_name = File.basename(request_path, ".html")+".yml"

        template_yml_path = theme_root.join('data',Pathname.new(template_yml_name))
        old_template_yml_path = theme_root.join(Pathname.new(template_yml_name))

        if old_template_yml_path.exist?
          result[:errors] << (Hammer.error "<code>#{old_template_yml_path}</code> location for this template yml file is being depreciated, please see <a href='https://github.com/wvuweb/hammer/wiki/Mock-Data#template-yml-override-file-location'>Template override Location in the Hammer wiki</a> for more information.", {depreciation: true})
          template_erb = ERB.new(old_template_yml_path.read, nil, '-')
          template_data = template_erb.result(binding)
          template_yml = HashWithIndifferentAccess.new(YAML::load(template_data))
          yml = yml.deep_merge template_yml
        end

        if template_yml_path.exist?
          template_erb = ERB.new(template_yml_path.read, nil, '-')
          template_data = template_erb.result(binding)
          template_yml = HashWithIndifferentAccess.new(YAML::load(template_data))
          yml = yml.deep_merge template_yml
        end

      else
        yml_path = Pathname.new(File.dirname(__FILE__)+'/../data/mock_data.yml')
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
