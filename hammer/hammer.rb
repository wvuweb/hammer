# encoding: utf-8
require "webrick"

require "../hammer/webrick_override.rb"
require "../hammer/services/theme_renderer.rb"

module Hammer

  def initialize(server, *options)
    super(server, *options)
    @server = server
    @document_root = document_root
    @filesystem_path = {}
    @request_path = {}
  end

  def do_GET(request, response)
    # binding.pry
    request_path(request)
    map_request

    puts "Handling a request for system path:".colorize(:light_magenta)+" #{@filesystem_path.to_s.colorize(:yellow)}\n"

    if @filesystem_path.directory?
      puts "Path is a Directory\n".colorize(:blue)
      directory = WEBrick::HTTPServlet::FileHandler.new(@server, @document_root, { FancyIndexing: true})
      directory.do_GET(request, response)
    else
      if request_radiusable_template?
        puts "Path is a #{get_mime_type} file\n".colorize(:blue)
        body = ThemeRenderer.new({
              :server => @server,
              :request => request,
              :document_root => @document_root,
              :filesystem_path => @filesystem_path,
              :request_path => @request_path,
              :content_type => get_mime_type
            }).render
        response.body = body
        response.content_type = get_mime_type+'; charset=utf-8'
      else
        if request.path == "/wvuhammer.css"
          puts "Path is the Hammer CSS File\n".colorize(:light_magenta)
          css_doc_root  = File.expand_path File.dirname(__FILE__)+"/css"
          file = WEBrick::HTTPServlet::FileHandler.new(@server, css_doc_root, { FancyIndexing: true })
          file.do_GET(request, response)
        else
          puts "Path is a Static #{get_mime_type} File\n".colorize(:blue)
          file = WEBrick::HTTPServlet::FileHandler.new(@server, @document_root, { FancyIndexing: true })
          file.do_GET(request, response)
        end
      end
    end

  end

  def document_root
    Pathname.new(@server.config[:DocumentRoot]).realpath
  end

  def request_path(request)
    @request_path = Pathname.new(request.path)
  end

  def request_radiusable_template?
    radiusable = %w(text/html application/xml application/atom+xml application/rss+xml application/json)
    radiusable.include?(get_mime_type)
  end

  def map_request
    @filesystem_path = @document_root.join(Pathname.new(@request_path.to_s.split('/').drop(1).join('/')))
  end

  def get_mime_type
    mime_file_path = File.expand_path('config/mime.types', File.dirname(__FILE__))
    mime_file = WEBrick::HTTPUtils::load_mime_types(mime_file_path)
    WEBrick::HTTPUtils::mime_type(@filesystem_path.to_s, mime_file)
  end

  def self.error(message, options={})
    options = {
      comment: false,
      message: "",
      warning: false
    }.merge(options)

    type = options[:warning] ? "Warning" : "Error"

    error_background_color = options[:warning] ? "#9BD3DD" : "red"
    error_text_color = options[:warning] ? "black" : "white"
    span_style = "color: #000; border: 1px dashed #{error_background_color}; background-color: #fff; border-radius: 3px; font-family: monospace; padding: 0 3px 0 0;"
    error_style= "color: #{error_text_color}; background-color: #{error_background_color}; border-radius: 3px 0 0 3px; padding: 0 3px; font-family: monospace;"

    console_error =  "Hammer #{type}: #{message.gsub(/(<[^>]*>)|\n|\t/s) {""}}"

    # puts console_error.colorize(:red)

    error = "<strong style='#{error_style}'>Hammer #{type}:</strong> #{message}"
    if options[:comment]
      "<!-- #{console_error} #{options[:message]} -->"
    else
      "<span style='#{span_style}'>#{error} #{options[:message]}</span>"
    end
  end

  def self.key_missing(key,options={})
    options = {
      parent_key: nil,
      comment: false,
      message: ""
    }.merge(options)

    style = "background-color: #eee; border-radius: 3px; font-family: monospace; padding: 0 3px;"
    if options[:parent_key]
      error("Missing key <code style='#{style}'>#{key}:</code> under <code style='#{style}'>#{options[:parent_key]}:</code> in mock_data.yml", options)
    else
      error("Missing key <code style='#{style}'>#{key}:</code> in mock_data.yml", options)
    end
  end

end
