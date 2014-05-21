# encoding: utf-8

require 'yaml'
require 'webrick'

require "../hammer/services/mock_data.rb"
require "../hammer/services/theme_context.rb"

class ThemeRenderer
  
  attr_accessor :config, :server, :request, :document_root, :filesystem_path, :request_root, :theme_root, :output
  attr_accessor :content, :layout_file_path, :data
  
  def initialize(options)
    @server = options[:server]
    @request = options[:request]
    @document_root = options[:document_root]
    @filesystem_path = options[:filesystem_path]
    @request_path = options[:request_path]
    @theme_root = theme_root
    @data = load_data
    @content = file_contents
    @output = ''
  end
  
  def theme_root
    config_path = Pathname.new('config.yml')
    
    @filesystem_path.ascend { |parent|
      if parent.directory?
        if parent.join(config_path).exist?
          puts "Theme directory: ".colorize(:light_magenta)+parent.to_s.split('/').last.to_s.colorize(:light_blue)
          return parent
        end
      end
    }
  end
  
  def load_data
    MockData.load(@theme_root)
  end
  
  def file_contents
    @filesystem_path.read
  end
  
  def has_layout?
    self.config['layout']
  end
  
  def layout_file_path
    file = self.config['layout']+'.html'
    folder = 'views/layouts'
    parts = [folder, file]
    layout_config_path = Pathname.new(parts.join('/'))
    if @theme_root.is_a?(Pathname)
      layout_file_path = @theme_root.join(layout_config_path)
    else
      raise 'Config File does not exist in theme see example: https://github.com/wvuweb/cleanslate-toolkit/blob/master/config.yml'
    end
    begin 
      layout_file_path.exist?
      layout_file_path
    rescue => e
      raise 'Layout File does not exist '+layout_file_path.to_s
    end
      
  end
  
  def layout_content
    @layout_content ||= layout_file_path.read
  end
  
  def render
    parse_yaml(@content)
    unless @content
      @content = file_contents
    end
    render_with_radius

  end
  
  def radius_parser(context = {})
    @radius_parser ||= Radius::Parser.new(context, :tag_prefix => 'r')
  end
  
  protected
  def parse_yaml(content)
    regex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
    match = regex.match(content)
    if match
      @content = match.post_match
      begin
        self.config = YAML.load(match[1])
      rescue => e
        raise 'Parsing template YAML config failed.'
      end
    end
    self.config ||= {}
  end
  
  def render_with_radius
    context = ThemeContext.new(self)
    parsed_content = radius_parser(context).parse(@content)
    radius_parser.context.globals.layout = false
    
    if has_layout?
      
      radius_parser.context.globals.yield = parsed_content
      radius_parser.context.globals.layout = true
      
      radius_parser.context.globals.layout_file_path = layout_file_path
      
      layout_content
      
      output = radius_parser.parse(self.layout_content)
      
      if self.data && self.data['livereload']
        @htmldoc = Nokogiri::HTML::Document.parse(output)
        script = Nokogiri::XML::Node.new "script", @htmldoc
        script['src'] = "http://localhost:35729/livereload.js"
        @htmldoc.at('head').add_child(script)
        output = @htmldoc.to_html
      end
      
      self.output << output
      
    else
      self.output << parsed_content
    end
    
  end
  
end