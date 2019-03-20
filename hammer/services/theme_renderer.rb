# encoding: utf-8

require 'yaml'
require 'webrick'
require 'chronic'

require "../hammer/services/mock_data.rb"
require "../hammer/services/theme_context.rb"

class ThemeRenderer

  attr_accessor :config, :server, :request, :document_root, :filesystem_path, :request_root, :theme_root, :output
  attr_accessor :content, :layout_file_path, :data, :data_errors

  def initialize(options)
    @server = options[:server]
    @request = options[:request]
    @document_root = options[:document_root]
    @filesystem_path = options[:filesystem_path]
    @request_path = options[:request_path]
    @content_type = options[:content_type]
    @theme_root = theme_root
    @data = load_data[:yml]
    @data_errors = load_data[:errors]
    @content = file_contents
    @htmldoc = ''
    @output = ''
  end

  def config_file
    Pathname.new('config.yml')
  end

  def theme_root
    @filesystem_path.ascend { |parent|
      if parent.directory?
        if parent.join(config_file).exist?
          # puts "Theme directory: ".colorize(:light_magenta)+parent.to_s.split('/').last.to_s.colorize(:light_blue)
          return parent
        end
      end
    }
  end

  def config_file_exists?
    File.exists? theme_root.join(config_file)
  end

  def config_file_path
    return theme_root.join(config_file)
  end

  def load_data
    MockData.load(@theme_root,@request_path)
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

  def hammer_nav_content
    hammer_nav_path = Pathname.new(File.expand_path File.dirname(__FILE__)+"/../views/_hammer_nav.html")
    @hammer_nav_content ||= hammer_nav_path.read
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
      rescue
        raise 'Parsing template YAML config failed.  Please validate your mock_data.yml file has the correct format: http://www.yamllint.com/'
      end
    end
    self.config ||= {}
    self.config.merge!(YAML::load(File.open(config_file_path))) if config_file_exists?
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

      html = radius_parser.parse(self.layout_content)
      @htmldoc = Nokogiri::HTML::Document.parse(html)

      output = insert_meta_tags
      output = insert_hammer_nav
      output = insert_style_tags

      if self.data_errors
        output = insert_errors_tags
      end

      if self.data && self.data['page'] && self.data['page']['javascript']
        output = insert_javascript_tags
      end
      self.output << output
    else
      self.output << parsed_content
    end
  end

  def insert_meta_tags
    begin
      meta = Nokogiri::XML::Node.new "meta", @htmldoc
      meta['http-equiv'] = "Content-Type"
      meta['content'] = "text/html; charset=UTF-8"
      @htmldoc.at('head').add_child(meta)
      @htmldoc.to_html
    rescue
      Hammer.error "Could not insert Hammer meta tags, your <code>head</code> tag may have an issue or doesn't exist."
    end
  end

  def insert_hammer_nav
    begin
      hammer_nav_content
      hammer_nav = radius_parser.parse(self.hammer_nav_content)

      @htmldoc.at('body').children.first.before(hammer_nav)
      @htmldoc.to_html
    rescue => e
      Hammer.error "Could not insert Hammer nav into your body tag may not exist. #{e}"
    end
  end

  def insert_style_tags
    begin
      # @htmldoc = Nokogiri::HTML::Document.parse(output)

      css_file_src = Pathname.new(File.expand_path File.dirname(__FILE__)+"/../css/wvu-hammer-inject.css").read
      css_file = "<style>"+css_file_src+"</style>"
      @htmldoc.at('head').add_child(css_file)
      @htmldoc.to_html
    rescue => e
      Hammer.error "Could not insert Hammer style tag, your <code>head</code> may have an issue or doesn't exist. #{e}"
    end
  end

  def insert_errors_tags
    begin
      # @htmldoc = Nokogiri::HTML::Document.parse(output)
      self.data_errors.each do |error|
        # @htmldoc.before(@htmldoc.at('body').first).add_child(error)
        @htmldoc.at('body').children.first.before(error)
      end
      @htmldoc.to_html
    rescue
      Hammer.error "Could not insert Hammer error tags, your <code>body</code> tag may have an issue or doesn't exist."
    end
  end

  def insert_javascript_tags
    begin
      script = Nokogiri::XML::Node.new "script", @htmldoc
      script.content = self.data['page']['javascript']
      @htmldoc.at('body').add_child(script)
      @htmldoc.to_html
    rescue
      Hammer.error "Could not insert Hammer javascript tags, your <code>body</code> tag may have an issue or doesn't exist."
    end
  end

end
