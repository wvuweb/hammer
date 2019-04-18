# encoding: utf-8
require "webrick"
require_relative "../hammer/webrick_override.rb"
require_relative "../hammer/services/theme_renderer.rb"

module Hammer

  def initialize(server, *options)
    super(server, *options)
    @server = server
    @document_root = document_root
    @filesystem_path = {}
    @request_path = {}
    @version = options.first[:version]
  end

  def do_GET(request, response)
    request_path(request)
    map_request

    puts "➜ #{@filesystem_path.to_s.colorize(:yellow)}\n"

    if @filesystem_path.directory?
      puts "⬅︎  Directory\n".colorize(:light_green)
      directory = WEBrick::HTTPServlet::FileHandler.new(@server, @document_root, { FancyIndexing: true})
      directory.do_GET(request, response)
    else
      if request_radiusable_template?
        puts "⬅︎  #{get_mime_type} file\n".colorize(:light_green)
        body = ThemeRenderer.new({
              :server => @server,
              :request => request,
              :document_root => @document_root,
              :filesystem_path => @filesystem_path,
              :request_path => @request_path,
              :content_type => get_mime_type,
              :version => @version
            }).render
        response.body = body
        response.content_type = get_mime_type+'; charset=utf-8'
      else
        if request.path == "/wvu-hammer-dir.css"
          puts "⬅︎  Hammer CSS File\n".colorize(:light_green)
          css_doc_root  = File.expand_path File.dirname(__FILE__)+"/css"
          file = WEBrick::HTTPServlet::FileHandler.new(@server, css_doc_root, { FancyIndexing: true })
          file.do_GET(request, response)
        else
          puts "⬅︎  #{get_mime_type} File\n".colorize(:light_green)
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
      warning: false,
      depreciation: false
    }.merge(options)

    type = options[:warning] ? "Warning" : "Error"
    if options[:depreciation]
      type = "Depreciation"
    end

    console_error =  "Hammer #{type}: #{message.gsub(/(<[^>]*>)|\n|\t/s) {""}}"
    console_color = options[:warning] ? :yellow : :red
    if options[:depreciation]
      console_color = :light_magenta
    end

    puts console_error.colorize(console_color)

    error = "<strong>Hammer #{type}:</strong> #{message}"
    if options[:comment]
      "<!-- #{console_error} #{options[:message]} -->"
    else
      "<span class='wvu-hammer-error wvu-hammer-error__#{type.downcase}'>#{error} #{options[:message]}</span>"
    end
  end

  def self.warning(message, options={})
    options = {
      comment: false,
      message: "",
      warning: true,
      depreciation: false
    }.merge(options)
    error(message, options)
  end

  def self.depreciation(message, options={})
    options = {
      comment: false,
      message: "",
      warning: false,
      depreciation: true
    }.merge(options)
    error(message, options)
  end

  def self.key_missing(key,options={})
    options = {
      parent_key: nil,
      comment: false,
      message: "",
      warning: true
    }.merge(options)

    if options[:parent_key]
      error("Missing key <code>#{key}:</code> under <code>#{options[:parent_key]}:</code> in mock_data.yml", options)
    else
      error("Missing key <code>#{key}:</code> in mock_data.yml", options)
    end
  end
end


class HammerServlet < WEBrick::HTTPServlet::AbstractServlet
  include Hammer
end
