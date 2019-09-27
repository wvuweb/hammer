# encoding: utf-8

require 'yaml'
require 'webrick'
require 'chronic'

require_relative "mock_data.rb"
require_relative "theme_context.rb"


class ThemeRendererError < StandardError
end

class ThemeRenderer

  attr_accessor :server, :request, :document_root, :filesystem_path, :request_root, :theme_root_path
  attr_accessor :config, :config_file_path, :output, :content, :layout_file_path, :data, :data_errors, :version, :version_behind

  def initialize(options)
    @server = options[:server]
    @request = options[:request]
    @document_root = options[:document_root]
    @filesystem_path = options[:filesystem_path]
    @request_path = options[:request_path]
    @content_type = options[:content_type]
    @theme_root_path = nil
    @config_file_path = find_config_file
    @config = load_config_file
    @theme_root_path = theme_root
    @theme_context = nil
    @data = nil
    @data_errors = nil
    @content = read_file_contents
    @htmldoc = ''
    @output = ''

    load_version(options)
    load_mock_data
  end

  def render
    @output = parse_radius_tags
  end

  def radius_parser
    @theme_context = ThemeContext.new(self)
    @radius_parser ||= Radius::Parser.new(@theme_context, :tag_prefix => 'r')
  end

  protected

  def theme_root
    @config_file_path.parent
  end

  def find_config_file
    config_file = Pathname.new 'config.yml'
    @filesystem_path.ascend { |parent|
      if parent.directory?
        if parent.join(config_file).exist?
          return parent.join(config_file)
        end
      end
    }
  end

  def load_config_file
    if @config_file_path == nil || !@config_file_path.exist?
      raise ThemeRendererError, "The theme does not include a config.yml file"
    else
      return YAML::load(File.open(@config_file_path))
    end
  end

  def read_file_contents
    @content ||= @filesystem_path.read
  end

  def has_layout?
    @config['layout'] ? true : false
  end

  def layout_file_path
    file = @config['layout']+'.html'
    folder = 'views/layouts'
    parts = [folder, file]
    layout_config_path = Pathname.new(parts.join('/'))
    if @theme_root_path.is_a?(Pathname)
      layout_file_path = @theme_root_path.join(layout_config_path)
    else
      raise 'Config File does not exist in theme see example: https://github.com/wvuweb/cleanslate-toolkit/blob/master/config.yml'
    end
    begin
      layout_file_path.exist?
      layout_file_path
    rescue => e
      raise 'Layout file does not exist '+layout_file_path.to_s+" #{e}"
    end

  end

  def set_layout_content
    @layout_content ||= layout_file_path.read
  end

  def hammer_nav_content
    hammer_nav_path = Pathname.new(File.expand_path File.dirname(__FILE__)+"/../views/_hammer_nav.html")
    @hammer_nav_content ||= hammer_nav_path.read
  end


  def parse_frontmatter(content)
    begin
      regex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      match = regex.match(content)
      if match
        @content = match.post_match
        @config = @config.merge! YAML.load(match[1])
      end
    rescue
      raise 'Parsing template YAML config failed.  Please validate your template frontmatter YAML has the correct format: http://www.yamllint.com/'
    end
  end

  def parse_radius_tags
    # Parse radius tag content
    parse_frontmatter(@content)
    content = radius_parser.parse(@content)
    radius_parser.context.globals.layout = has_layout?
    if @content_type == 'text/html'

      if has_layout?
        set_layout_content
        # Set the fragment content to yield
        radius_parser.context.globals.yield = content
        content = radius_parser.parse(@layout_content)
      end
      @htmldoc = nokogiri_parse(content)
      # If the file is not html content just return the original parsed content
      post_process
    else
      # Return parsed document
      content
    end
  end

  def nokogiri_parse(html)
    Nokogiri::HTML::Document.parse(html)
  end

  def post_process
    # If the request is an html document
    insert_meta_tags
    insert_style_tags
    insert_hammer_nav

    if @data_errors.count > 0
      insert_errors_tags
    end
    if @data && @data['page'] && @data['page']['javascript']
      insert_javascript_tags
    end
    @output = @htmldoc.to_html
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
      hammer_nav = radius_parser.parse(@hammer_nav_content)

      @htmldoc.at('body').children.first.before(hammer_nav)
      @htmldoc.to_html
    rescue => e
      Hammer.error "Could not insert Hammer nav into your body tag may not exist. #{e}"
    end
  end

  def insert_style_tags
    begin
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
      @htmldoc.at_css('.wvu-hammer-version').add_child("<a href='#wvu-hammer-errors' class='wvu-hammer-btn wvu-hammer-pill' title='#{@data_errors.count.to_s} Hammer Messages'></a>")
      @htmldoc.at_css('.wvu-hammer-btn').content = @data_errors.count.to_s
      @htmldoc.at_css('#wvu-hammer-nav').after("<div id='wvu-hammer-errors'></div>")
      @data_errors.each do |error|
        @htmldoc.at_css('#wvu-hammer-errors').add_child(error)
      end
      @htmldoc.to_html
    rescue => e
      Hammer.error "Could not insert Hammer error tags, your <code>body</code> tag may have an issue or doesn't exist. #{e} #{e.backtrace.first}"
    end
  end

  def insert_javascript_tags
    begin
      script = Nokogiri::XML::Node.new "script", @htmldoc
      script.content = @data['page']['javascript']
      @htmldoc.at('body').add_child(script)
      @htmldoc.to_html
    rescue
      Hammer.error "Could not insert Hammer javascript tags, your <code>body</code> tag may have an issue or doesn't exist."
    end
  end

  def load_mock_data
    mock_data = MockData.new(@theme_root_path,@request_path)
    @data = mock_data.yml
    @data_errors = mock_data.errors
  end

  def load_version(options)
    if options[:version].split('-')[1] != nil
      @version = options[:version].split('-')
    else
      @version = options[:version]
    end
    @version_behind = options[:version_behind]
  end
end
