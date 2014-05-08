class ThemePartialRenderer
  
  def initialize(args)
    @template = args[:template]
    @context = args[:context]
  end
  
  def partial_name
    partial_parts = @template.split('/')
    if partial_parts.length > 1
      template = partial_parts.first+'/_'+partial_parts.last+'.html'
    else
      folder = @context.layout_file.split("/").reverse.drop(1).reverse.last
      'views/'+folder+'/_'+partial_parts.first+'.html'
    end
  end
  
  def file_path
    [@context.theme,partial_name].join('/')
  end
  
  def shared_file
    shared_folder = @context.theme.split('/').reverse.drop(1).reverse.join('/')
    shared = [shared_folder,'code/views',partial_name].join('/')
    puts "Checking for partial in shared folder: #{shared}".colorize(:yellow)
    shared
  end
  
  def render()
    if File.exists?(file_path)
      content = File.read file_path
      @context.radius_parser.parse content
    else
      
      if File.exists?(shared_file)
        content = File.read shared_file
        @context.radius_parser.parse content
      else
        
        puts "Not Found:".colorize(:red)
        puts file_path.colorize(:black).on_red
        puts " "
      
        "Partial not found"
        
      end

    end
    
  end
  
end