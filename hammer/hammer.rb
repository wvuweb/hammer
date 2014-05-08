# encoding: utf-8
require "webrick"
require "../hammer/services/theme_renderer.rb"

module Hammer
  
  def initialize(server, *options)
    super(server, *options)
    @server = @config = server
    @logger = @server[:Logger]
    @options = options
    @theme_directory = theme
  end
  
  def file_path(theme_dir,request)
    doc_root = document_root.split("/")
    req_path = request.path.split("/")
    File.join(doc_root,req_path)
  end
  
  def document_root
    @server.config[:DocumentRoot]
  end
  
  def is_directory?(req)
    File.directory?(req)
  end
  
  def is_html?(req)
    get_mime(req) == "text/html"
  end
  
  def get_mime(req)
    WEBrick::HTTPUtils::mime_type(req, @server.config[:MimeTypes])
  end
  
  def theme
    parts = document_root.split("/")
    if parts.last == "cleanslate_themes"
      false
    else
      document_root
    end
  end
  
  def theme_from_request(request)
    theme_folder = request.path.split('/')[1]
    @theme_directory = File.join(document_root.split('/'),theme_folder)
  end
  
  def do_GET(request, response)

    begin
      
      req = file_path(document_root,request)
      
      if is_directory?(req)
        
        puts " "
        puts "Loading directory: #{req}".colorize(:red)
        puts " "
        
        if theme
          theme_dir = @theme_directory
        else
          theme_dir = @server.config[:DocumentRoot]
        end
        
        directory = WEBrick::HTTPServlet::FileHandler.new(@server, theme_dir, { :FancyIndexing =>true })
        directory.do_GET(request, response)
      
        else
          
          if !theme
            theme_from_request(request)
          end
          
          if is_html?(req)
        
            puts " "
            puts "Loading html: #{req}".colorize(:green)
            puts " "
        
            response.status = 200
            response.body = ThemeRenderer.new({:theme => @theme_directory, :request => request, :response => response, :server => @server}).render
            response['content-type'] = get_mime(req)
      
          else
            puts " "
            puts "#{get_mime(req)}".colorize(:blue)
            puts "Loading file: #{req}".colorize(:blue)
            puts " "
            
            file = WEBrick::HTTPServlet::FileHandler.new(@server, req, { :FancyIndexing =>false })
            file.do_GET(request, response)
          end
      end
      
    rescue StandardError => exception
      raise
    rescue Exception => exception
      raise
    end
  end
  
  def self.const_missing(c)
    Object.const_get(c)
  end
  
end