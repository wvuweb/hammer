
class ThemePartialRenderer
  def initialize(args)
    @tag = args[:tag]
    @template = args[:template]
    @opts = args[:opts]
    @theme = load_theme(args[:theme])

    # @parser = @template.radius_parser
  end

  def render(name, options = {})
    options = options.with_indifferent_access
    file_name = normalize_partial_name(name, options)
    file_path = find_partial(file_name)

    # raise Slate::Errors::TemplateNotFound.new("Could not find partial '#{file_name}' in '#{@theme.name}' theme.") unless file_path.present?

    unless file_path.present?
      if @theme.nil?
        content = "Partial Not Found: Could not find partial '#{file_name}' is '#{@opts['theme']}' listed in your mock_data.yml?"
      else
        content = "Partial Not Found: Could not find partial '#{file_name}' in '#{@theme}' theme."
      end

    else
      content = File.read file_path
    end

    @tag.globals.context.radius_parser.parse content

    # @parser.parse content
  end

  private

  def load_theme(shared_theme = nil)
    theme = if shared_theme.nil?
      @tag.globals.context.theme_root
    else
      # @tag.globals.context.data['shared_themes'][shared_theme][@opts[:name]]

      if @tag.globals.context.data['shared_themes'] && @tag.globals.context.data['shared_themes'][shared_theme] && @tag.globals.context.data['shared_themes'][shared_theme][@opts[:name]]
        Pathname.new([@tag.globals.context.document_root,@tag.globals.context.data['shared_themes'][shared_theme][@opts[:name]]].join('/'))
      else
        nil
      end
    end

    # raise Slate::Errors::TemplateNotFound.new("Could not find theme: #{theme_name}") unless theme.present?
    theme

  end


  def load_paths
    # Paths in order of significance:
    # - The template directory set via the current Radius parser
    # - The directory of the current template
    # - The template directory of the Theme passed into this ThemePartialRenderer
    #
    # The paths will be searched in the order above for the named partial.
    # [@parser.context.globals.template_dir, @template.file_path, @theme.template_dir].compact

    context_path = @tag.globals.context.filesystem_path.parent
    theme_dir = Pathname.new([@theme,'views'].join('/'))
    file_path = Pathname.new(@template.parent)
    layouts_path = Pathname.new([theme_dir,'layouts'].join('/'))
    paths = [context_path, file_path, theme_dir,layouts_path].compact

    paths

  end

  def find_partial(name)
    load_paths.map{ |path| File.join(path, name) }.select { |path| File.exists? path }.first
  end

  def default_format
    if get_mime_type == "application/rss+xml"
      '.rss'
    else
      '.html'
    end
  end

  def normalize_partial_name(name, options = {})
    return nil unless name.present?

    dirname = File.dirname(name)
    extension = File.extname(name)
    basename = File.basename(name, extension)

    filename = basename
    filename = filename.prepend('_') unless filename[0] == '_'
    filename += "-#{options['version']}" if options['version'].present?
    filename += extension.present? ? extension : default_format

    dirname == '.' ? filename : File.join(dirname, filename)
  end

  def get_mime_type
    mime_file_path = File.expand_path('../config/mime.types', File.dirname(__FILE__))
    mime_file = WEBrick::HTTPUtils::load_mime_types(mime_file_path)
    WEBrick::HTTPUtils::mime_type(@template.to_s, mime_file)
  end

  #   protected
  #   def render_with_radius
  #     @context.radius_parser.parse @content
  #   end
end
