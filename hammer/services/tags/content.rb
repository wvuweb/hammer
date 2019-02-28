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
        if tag.globals.yield.empty?
          Hammer.error "No yield data.  Are you trying to view a layout?"
        else
          tag.globals.yield
        end
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
      # if tag.globals.context.data
      #   if tag.globals.context.data['editable_region'] && tag.globals.context.data['editable_region'][tag.attr['name']]
      #     content = tag.globals.context.data['editable_region'][tag.attr['name']]
      #   else
      #     content = Hammer.error "Set data for key: <em>#{tag.attr['name']}</em> under <em>editable_region</em> in the mock_data file"
      #   end
      # else
      #   content = Faker::Lorem.paragraph(rand(2..10))
      # end
      # if tag.globals.context.data['show_editable_regions']
      #   if tag.attr['scope'] == "site"
      #     "<div class='hammer-show-editable' style='outline: 1px dotted orange;'>"+content+"</div>"
      #   else
      #     "<div class='hammer-show-editable' style='outline: 1px dotted #09F;'>"+content+"</div>"
      #   end
      # else
      #   content
      # end
      rname = tag.attr["name"]
      if tag.globals.context.data['editable_region']
        if tag.globals.context.data['editable_region'][rname]
          tag.globals.context.data['editable_region'][rname]
        else
          content = []
          content << (Hammer.key_missing rname, {parent_key: "editable_region", warning: true, message: "auto generated paragraph added below"})
          content << "<p>#{Faker::Lorem.paragraph(rand(2..10))}</p>"
          content.join("")
        end
      else
        Hammer.key_missing "editable_region"
      end

    end

    # The contents of this tag will only be rendered/accessible in the editor. This could be used, for example, to
    # provide access to content regions that for administrative/special purposes only and shouldn't be display
    # for the world. Once content within the regions is published/saved, it will be available for display in other
    # templates, if desired.
    tag 'edit_mode_only' do |tag|
      # if tag.globals.mode == Slate::ViewModes::EDIT
      if tag.globals.context.data['edit_mode'] == true
        tag.expand
      end
    end

    tag 'partial' do |tag|

      options = tag.attr.with_indifferent_access
      tag_opts = tag.attr.with_indifferent_access
      name = options.delete(:name)
      theme = options.delete(:theme)

      ThemePartialRenderer.new(template: tag.globals.context.filesystem_path, theme: theme, tag: tag, opts: tag_opts).render(name, options)

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
