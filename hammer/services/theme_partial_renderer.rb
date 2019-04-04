
class ThemePartialRenderer
  def initialize(tag)
    @tag = tag
    @template = tag.globals.context.filesystem_path
    @opts = tag.attr.with_indifferent_access
    @init_error = nil
    # if it is a shared theme partial
    unless @opts[:theme].nil?
      if tag.globals.context.data['version'] == 2
        @theme = Pathname.new([tag.globals.context.document_root, tag.globals.context.data['shared_themes']["#{tag.attr['theme']}"]].join('/'))
      else
        @theme = Pathname.new([tag.globals.context.document_root, @tag.globals.context.data['shared_themes'][@opts[:theme]][@opts[:name]]].join('/'))
        @init_error = Hammer.error "This mock data format for <code>shared_themes</code> is being depreciated, please see <a href='https://github.com/wvuweb/hammer/wiki'>Hammer wiki</a> for version 2 information.", {warning: true}
      end
    else
      @theme = tag.globals.context.theme_root
    end
  end

  def render
    file_name = normalize_partial_name(@opts[:name], @opts)
    file_path = find_partial(file_name)

    unless file_path.present?
      if @theme.nil?
        content = Hammer.error "Partial Not Found: Could not find partial <code>#{file_name}</code> is the #{@opts['theme']} theme listed under <code>shared_themes:</code> your mock_data.yml?"
      else
        content = Hammer.error "Partial Not Found: Could not find partial <code>#{file_name}</code> in #{@theme} theme."
      end
    else
      content = File.read file_path
      content << @init_error unless @init_error.nil?
    end
    @tag.globals.context.radius_parser.parse content
  end

  private

  def load_paths
    # Paths in order of significance:
    # - The template directory set via the current Radius parser
    # - The directory of the current template
    # - The template directory of the Theme passed into this ThemePartialRenderer
    #
    # The paths will be searched in the order above for the named partial.
    # Path in which is currently loaded
    current_file_path = Pathname.new(@template.parent)
    # Theme views directory  theme/views
    theme_views_path = Pathname.new([@theme,'views'].join('/'))
    # Theme layouts directory theme/views/layouts
    theme_layouts_path = Pathname.new([theme_views_path,'layouts'].join('/'))
    # return only unique results
    paths = [current_file_path, theme_views_path,theme_layouts_path].compact
    paths
  end

  def find_partial(name)
    load_paths.map{ |path| File.join(path, name)}.select {|path| File.exists?(path) }.first
  end

  def default_format
    if get_mime_type == "application/rss+xml"
      '.rss'
    elsif get_mime_type == 'application/json'
      ".json"
    else
      '.html'
    end
  end

  def normalize_partial_name(name, options = {})
    return nil unless name.present?
    name.sub!(/^\//, '')
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

end
