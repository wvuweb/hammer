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

  attr_reader :yml, :errors

  def initialize(theme_root_path, request_path)
    @theme_root_path = theme_root_path
    @yml_path = @theme_root_path.join(Pathname.new('mock_data.yml'))
    @request_path = request_path
    @errors = []
    @yml = ""
    load
  end

  protected



  def load

    # # Deep Merging of yml files using map reduce
    # yml_files = []
    # # Load default mock data
    # yml << Pathname.new(File.dirname(__FILE__)+'/../data/mock_data.yml')
    #
    # # Load Theme Root mock_data.yml
    # theme_root_yml = theme_root_path.join(Pathname.new('mock_data.yml'))
    # if theme_root_yml
    #   yml_files << theme_root_yml
    # end
    #
    # # Load Template YAML files
    # template_yml = theme_root_path.join('data',Pathname.new(File.basename(request_path, ".html")+".yml"))
    # old_path_template_yml =  theme_root_path.join(Pathname.new(File.basename(request_path, ".html")+".yml"))
    # if template_yml.exist?
    #   yml_files << template_yml
    # elseif old_path_template_yml.exist?
    #   yml_files << old_path_template_yml
    # end
    # TODO: Parse new yml
    # combined_yml = yml_files.map{ |file| YAML.load_file(file) }.reduce( {}, :deep_merge!)
    # TODO: Erb parse new combined YML

    YAML.set_file_root(@theme_root_path)

    if @yml_path.exist?
      # Parse ERB
      erb_data = parse_erb(@yml_path)
      begin
        @yml = HashWithIndifferentAccess.new(YAML::load(erb_data))
      rescue Psych::SyntaxError => e
        line_message = e.message.to_s
        if line_message.include?("at line")
          line_message = line_message.partition('at line')[-2] + line_message.partition('at line')[-1]
        end
        raise YamlIncludeError, "There is an error in your mock_data.yml file #{line_message} (line # includes any included partial YAML files)"
      end
      # Merge Template YAML
      @yml.deep_merge template_yml_load
    else
      yml_path = Pathname.new(File.dirname(__FILE__)+'/../data/mock_data.yml')
      data = parse_erb(yml_path)
      @yml = HashWithIndifferentAccess.new(YAML::load(data))
      @errors << (Hammer.error "Your theme does not include a mock_data.yml")
    end
    depreciation_check
    @yml


  end

  def template_yml_load
    template_yml_file = File.basename(@request_path, ".html")+".yml"

    # check old path
    if old_template_yml_path(template_yml_file).exist?
      return load_old_template_path(template_yml_file)
    end

    # check data/ path
    if template_yml_path(template_yml_file).exist?
      return load_new_template_path
    end

    HashWithIndifferentAccess.new
  end

  def load_old_template_path(template_yml_file)
    @errors << (Hammer.error "<code>#{old_template_yml_path(template_yml_file)}</code> location for this template yml file is depreciated and will be removed in the next version of hammer, please see <a href='https://github.com/wvuweb/hammer/wiki/Mock-Data#template-yml-override-file-location'>Template override Location in the Hammer wiki</a> for more information on how to update.", {depreciation: true})
    template_erb = ERB.new(old_template_yml_path(template_yml_file).read, nil, '-')
    template_data = template_erb.result(binding)
    HashWithIndifferentAccess.new(YAML::load(template_data))
  end

  def load_template_path
    template_erb = ERB.new(template_yml_path.read, nil, '-')
    template_data = template_erb.result(binding)
    HashWithIndifferentAccess.new(YAML::load(template_data))
  end

  def depreciation_check
    # Check for older shared_themes syntax
    if !@yml['shared_themes'].nil? && @yml['shared_themes'].first[1].class == HashWithIndifferentAccess
      @errors << (Hammer.error "The mock data syntax you are using for <code>shared_themes:</code> is depreciated amd will be removed in the next version of hammer, please see <a href='https://github.com/wvuweb/hammer/wiki/Mock-Data#shared-themes-syntax'>Shared Theme Syntax in the Hammer wiki</a> for more information on how to upgrade.", {depreciation: true})
    end
  end

  def template_yml_path(template_yml_file)
    @theme_root_path.join('data',Pathname.new(template_yml_file))
  end

  def old_template_yml_path(template_yml_file)
    @theme_root_path.join('data',Pathname.new(template_yml_file))
  end

  def parse_erb(path)
    # Parse ERB
    erb = ERB.new(path.read, nil, '-')
    erb.result(binding)
  end

end
