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
      puts "Partial Loaded from: ".colorize(:green)+@filesystem_path.to_s.colorize(:green)
      @content = @filesystem_path.read
      render_with_radius
    else
      @content = 'Partial Not Found: '+@filesystem_path.to_s
    end
    
  end
  
  
  protected
  def render_with_radius
    @context.radius_parser.parse @content
  end
  
end