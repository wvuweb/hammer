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

    puts "Requesting system path: ".colorize(:light_magenta)
    puts map_request.to_s.colorize(:yellow)

    if @filesystem_path.directory?
      puts "Path is a Directory".colorize(:blue)

      directory = WEBrick::HTTPServlet::FileHandler.new(@server, @document_root, { :FancyIndexing =>true })
      directory.do_GET(request, response)

    else
      if request_html?
        puts "Path is a #{get_mime_type} file".colorize(:blue)

        response.status = 200

        response.body = ThemeRenderer.new(
          {
            :server => @server,
            :request => request,
            :document_root => @document_root,
            :filesystem_path => @filesystem_path,
            :request_path => @request_path,
            :content_type => get_mime_type
          }
        ).render
        response['content-type'] = get_mime_type

      else
        puts "Path is a File".colorize(:blue)

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

  def request_html?
    get_mime_type == "text/html" || "application/rss+xml"
  end

  def map_request
    @filesystem_path = @document_root.join(Pathname.new(@request_path.to_s.split('/').drop(1).join('/')))
  end

  def get_mime_type
    mime_type = WEBrick::HTTPUtils::load_mime_types(Pathname.new(Dir.pwd + '/config/mime.types'))
    WEBrick::HTTPUtils::mime_type(@filesystem_path.to_s, mime_type)
  end

  def self.error(message)
    "<strong>Hammer: </strong> #{message}"
  end

end
