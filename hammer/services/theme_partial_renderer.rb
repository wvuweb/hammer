class ThemePartialRenderer
  
  def initialize(options)
    @context = options[:context]
    @partial_path = options[:partial_path]
    @filesystem_path = options[:filesystem_path]
    @content = ""
  end
  
  def render
    @content = ""
    
    if @filesystem_path.exist?
      puts "Partial Found at: ".colorize(:green)+@filesystem_path.to_s.colorize(:green)
      @content = @filesystem_path.read
      render_with_radius
    else
      shared_file_path = shared_theme_path(@filesytem_path)
      
      puts '####'.colorize(:green)
      puts shared_file_path
      puts '####'.colorize(:green)
      
      if shared_file_path.exist?
        @content = shared_file_path.read
        render_with_radius
      else
        @content = 'Partial Not Found: '+@filesystem_path.to_s
      end
    end
    
  end
  
  def shared_theme_path(path)
    themes_root = @context.theme_root.parent
    code_path = Pathname.new('code/views')
    themes_root.join(code_path, @partial_path)
  end
  
  protected
  def render_with_radius
    @context.radius_parser.parse @content
  end
  
end