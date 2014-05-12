require 'active_support/all'
require 'faker'
require "../hammer/services/theme_partial_renderer.rb"

module Tags  
  class Content < TagContainer
    tag 'yield' do |tag|
      name = tag.attr['name']
      tag.globals.yield ||= ''
      tag.globals.content_for ||= {}
      
      # If a name is given, retrieve the saved content by name; otherwise, retrieve the default stored content.
      tag.locals.content = if name 
        tag.globals.content_for[name]
      else
        tag.globals.yield
      end
      
      return nil unless tag.locals.content.present?
      
      if tag.double?
        tag.expand
      else
        tag.locals.content
      end
      
    end
    
    tag 'yield:content' do |tag|
      tag.locals.content
    end
    
    # Only evaluate/output the tag's content if content has be set via content_for for the given name.
    tag 'if_content_for' do |tag|
      content_for = tag.globals.content_for ||= {}
      tag.expand if content_for[tag.attr['name']].present?
    end
    
    tag 'content_for' do |tag|
      tag.globals.content_for ||= {}
      name = tag.attr['name']
      (tag.globals.content_for[name] ||= '') << tag.expand
      # We return nil here because we've stored the rendered content for future use.
      nil
    end

    tag 'editable_region' do |tag|    
      if tag.globals.context.data
        if tag.globals.context.data['editable_region'] && tag.globals.context.data['editable_region'][tag.attr['name']]
          if is_num?(tag.globals.context.data['editable_region'][tag.attr['name']])
            content = ""
            content_array = Faker::Lorem.paragraphs(tag.globals.context.data['editable_region'][tag.attr['name']].to_i)
            content_array.each do |c|
              content << "<p>"+c+"</p>"
            end
          else
            content = tag.globals.context.data['editable_region'][tag.attr['name']]
          end
        else
          content = "<strong>Hammer:</strong> Set data for key: <em>#{tag.attr['name']}</em> under <em>editable_region</em> in the mock_data file"
        end
      else
        content = Faker::Lorem.paragraph(rand(2..10))
      end
      content

    end
    
    tag 'partial' do |tag|
      
      if tag.attr['theme']
        tag_name = tag.attr['name'].split('/').join('__')
        if tag.globals.context.data
          if tag.globals.context.data['shared_themes'] && tag.globals.context.data['shared_themes'][tag_name]
            partial_path = self.partial_file_path(tag.attr['name'])
            directory_dir = Pathname.new(tag.globals.context.data['shared_themes'][tag_name]+'/views')
            partial_dir = tag.globals.context.theme_root.parent.join(directory_dir)
            
            partial_request_path = partial_dir.join(partial_path)
            
          else
            return "<strong>Hammer:</strong> Add key: <em>#{tag_name}</em> under <em>shared_themes:</em> with a local path of <em>#{tag.attr['theme'].downcase}</em> in the mock_data file"
          end
        else
          return "<strong>Hammer:</strong>Add key: <em>#{tag_name}</em> under <em>shared_themes:</em> with a local path of <em>#{tag.attr['theme'].downcase}</em> in the mock_data file"
        end
        
      else 
        partial_path = self.partial_file_path(tag.attr['name'])
        partial_dir = tag.globals.context.filesystem_path.dirname
        
        if tag.globals.context.radius_parser.context.globals.layout
          parent_dir = tag.globals.context.layout_file_path.dirname
          partial_request_path = parent_dir.join(partial_path)
        else
          partial_request_path = partial_dir.join(partial_path)
        end
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
    
    def self.is_num?(str)
      begin
        !!Integer(str)
      rescue ArgumentError, TypeError
        false
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
