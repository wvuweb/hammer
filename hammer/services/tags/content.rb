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
          Hammer.error "No yield data. Are you viewing a layout?", {warning: true}
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
      rname = tag.attr["name"]
      if tag.globals.context.data['editable_region']
        if tag.globals.context.data['editable_region'][rname]
          tag.globals.context.data['editable_region'][rname]
        else
          content = []
          content << (Hammer.key_missing rname, {parent_key: "editable_region", warning: true, message: "auto-generated paragraph added below"})
          Faker::Lorem.paragraphs(rand(1..3), true).each do |paragraph|
            content << "<p>#{paragraph}</p>"
          end
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
      name = tag.attr[:name]
      theme = tag.attr[:theme]
      if tag.attr[:theme]
        if tag.globals.context.data['shared_themes'].nil?
          return Hammer.key_missing "shared_themes", {message: "can't load shared partial: <code>#{name}</code>"}
        end
        if tag.globals.context.data['shared_themes']["#{theme}"].nil?
          return Hammer.key_missing "shared_themes:#{theme}", {message: "can't load shared partial: <code>#{name}</code>"}
        end
      end
      ThemePartialRenderer.new(tag).render
    end
  end
end
