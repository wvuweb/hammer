# encoding: utf-8
require "webrick"
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

    request_path(request)

    puts "Handling a request for system path:".colorize(:light_magenta)+" #{map_request.to_s.colorize(:yellow)}\n"

    if @filesystem_path.directory?
      puts "Path is a Directory\n".colorize(:blue)
      directory = WEBrick::HTTPServlet::FileHandler.new(@server, @document_root, { :FancyIndexing =>true })
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
        puts "Path is a Static #{get_mime_type} File\n".colorize(:blue)
        file = WEBrick::HTTPServlet::FileHandler.new(@server, @document_root, { :FancyIndexing =>true })
        file.do_GET(request, response)
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

  def self.error(message)
    "<strong>Hammer Error: </strong> #{message}"
  end

end
