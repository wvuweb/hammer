# encoding: utf-8

require 'yaml'
require 'webrick'

# Dir["./hammer/helpers/*.rb"].each {|file|
#   puts 'requiring helper '+file+'...'
#   require file 
# }
# Dir["./hammer/models/*.rb"].each {|file|
#   puts 'requiring model '+file+'...'
#   require file 
# }

require "../hammer/services/mock_data.rb"
require "../hammer/services/theme_context.rb"

class ThemeRenderer
  
  attr_accessor :config, :content, :layout_content, :output, :theme, :file_path, :layout_file, :request, :server

  def initialize(options)
    @theme = options[:theme]
    @server = options[:server]
    @request = options[:request]
    @response = options[:response]
    @data = load_data
    @file_path = @server.config[:DocumentRoot]+''+@request.path
    @output = ''
  end
  
  def load_data
    MockData.load(@theme)
  end
  
  def has_layout?
    self.config['layout']
  end
  
  def render
    parse_yaml(self.content)
    render_with_radius
  end
  
  def radius_parser(context = {})
    @radius_parser ||= Radius::Parser.new(context, :tag_prefix => 'r')
  end
  
  def content
    @content ||= File.read(@file_path)
  end
  
  def layout_file
    if self.config != {}
      theme+'/views/layouts/'+self.config['layout']+'.html'
    else
      self.file_path
    end
  end
  
  def layout_content
    @layout_content ||= File.read(layout_file)
  end
  
  protected
  
  def render_with_radius
    
    context = ThemeContext.new(self)
    parsed_content = radius_parser(context).parse(self.content)
    
    self.output << if has_layout?
      
      radius_parser.context.globals.yield = radius_parser(context).parse(parsed_content)
      
      radius_parser.parse(self.layout_content)
      
    else
      parsed_content
    end
    
  end
  
  def parse_yaml(content)
    regex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
    match = regex.match(content)
    if match
      self.content = match.post_match
      begin
        self.config = YAML.load(match[1])
      rescue => e
        raise 'Parsing template YAML config failed.'
      end
    end
    self.config ||= {}
  end
  
end