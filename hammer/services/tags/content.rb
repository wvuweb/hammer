require "../hammer/services/theme_partial_renderer.rb"

module Tags  
  class Content < TagContainer
    tag 'yield' do |tag|
      # name = tag.attr['name']
      # tag.globals.yield ||= ''
      # tag.globals.content_for ||= {}
      # 
      # # If a name is given, retrieve the saved content by name; otherwise, retrieve the default stored content.
      # tag.locals.content = if name 
      #   tag.globals.content_for[name]
      # else
      #   tag.globals.yield
      # end
      # 
      # return nil unless tag.locals.content.present?
      # 
      # if tag.double?
      #   tag.expand
      # else
      #   tag.locals.content
      # end
      
      unless tag.attr['name']
        tag.globals.yield
      else
        "fix named yeilds"
      end
      # binding.pry
      
      # "fix yeild tag"
    end
    
    tag 'yield:content' do |tag|
      # tag.locals.content
      "fix yeild:content tag"
    end
    
    # Only evaluate/output the tag's content if content has be set via content_for for the given name.
    tag 'if_content_for' do |tag|
      # content_for = tag.globals.content_for ||= {}
      # tag.expand if content_for[tag.attr['name']].present?
      "fix if_content_for tag"
    end
    
    tag 'content_for' do |tag|
      # tag.globals.content_for ||= {}
      # name = tag.attr['name']
      # (tag.globals.content_for[name] ||= '') << tag.expand
      # 
      # # We return nil here because we've stored the rendered content for future use.
      # nil
      "fix content region tag"
    end

    tag 'editable_region' do |tag|
      # @tag = tag
      # @page = tag.globals.page
      # @site = tag.globals.site
      # @mode = tag.globals.mode
      # @area = find_area(tag.attr['name'])
      # 
      # content = get_content @area
      # 
      # if @mode == Slate::ViewModes::EDIT
      #   render_editable(content)
      # else
      #   content
      # end
      content = "fix editable region tag to generate Lorem Ipsum"
      if tag.globals.context.data
        if tag.globals.context.data['editable_region'][tag.attr['name']]
          content = tag.globals.context.data['editable_region'][tag.attr['name']]
        end 
      end
      content

    end
    
    tag 'partial' do |tag|
      # options = tag.attr.with_indifferent_access
      # name = options.delete(:name)
      # theme = options.delete(:theme)
      # 
      # # If the 'preview' flag is set in the query string, attempt to render the preview version of the partial.
      # if %w(1 t true on).include?((tag.globals.vars['preview'] || '').downcase)
      #   opts = options.dup
      #   opts[:version] = 'preview'
      #   
      #   content = ThemePartialRenderer.new(template: tag.globals.page_template, theme: theme).render(name, opts) rescue nil
      # end
      # 
      # # Render the partial, unless the preview version was already rendered.
      # content ||= begin
      #   ThemePartialRenderer.new(template: tag.globals.page_template, theme: theme).render(name, options)
      # rescue Slate::Errors::TemplateNotFound => e
      #   e.message
      # end
      # 
      # content
      # binding.pry
      #ThemePartialRenderer.new(template: tag.attr['name'], context: tag.globals.context).render()
      
      partial_path = self.partial_file_path(tag.attr['name'])
      partial_dir = tag.globals.context.filesystem_path.dirname
      test_dir = partial_dir
      
      if tag.globals.context.radius_parser.context.globals.layout
        parent_dir = tag.globals.context.layout_file_path.dirname
        test_dir = parent_dir
        partial_request_path = parent_dir.join(partial_path)
      else
        partial_request_path = partial_dir.join(partial_path)
      end
      
      content = ThemePartialRenderer.new(
        {
          :context => tag.globals.context,
          :filesystem_path => partial_request_path,
          :partial_path => partial_path
        }
      ).render
    end
    
    def self.partial_file_path(name)
      parts = name.split('/')
      if parts.length == 1
        Pathname.new('_'+parts.first+'.html')
      else
        parts[-1] = '_'+parts.last+'.html'
        Pathname.new(parts.join('/'))
      end
    end
    
    # def self.find_area(key)
    #   area = nil
    #   [@page, @site].each do |target|
    #     area = target.areas.includes(:snippets).find_by_key(key)
    #     break if area
    #   end
    #   area
    # end
    # 
    # def self.get_content(area)
    #   if area
    #     ContentAreaDecorator.decorate(area).rendered_content(:mode => @mode, :context => @tag.globals.context)
    #   else
    #     if @mode == Slate::ViewModes::EDIT
    #       @tag.double? ? @tag.expand : ''
    #     else
    #       nil
    #     end
    #   end
    # end
    # 
    # def self.render_editable(content)
    #   scope = @tag.attr['scope'] || ContentArea::PAGE_SCOPE
    #   status = @area && @area.has_draft_content? ? 'draft' : nil
    #   region_type = @tag.attr['type'] || 'full'
    #   id = Mercury::Area.prepare_key(@tag.attr['name'])
    #   div_class = [scope, status].compact.join(' ')
    #   content_tag :div, content.strip.html_safe, :id => id, :class => div_class, :data => { :mercury => region_type, :scope => scope }
    # end
  end
end