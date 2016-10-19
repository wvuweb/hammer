require 'active_support/core_ext/string/output_safety'

module Tags

  class ThemeAsset < TagContainer

    BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked autobuffer
                         autoplay controls loop selected hidden scoped async
                         defer reversed ismap seamless muted required
                         autofocus novalidate formnovalidate open pubdate
                         itemscope allowfullscreen default inert sortable
                         truespeed typemustmatch).to_set
    BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map {|attribute| attribute.to_sym })
    PRE_CONTENT_STRINGS = {
      :textarea => "\n"
    }

    # <r:include_stylesheet name="bootstrap, main" compress="true|false" join="true|false"
    tag 'include_stylesheet' do |tag|
      # site = tag.globals.site
      # theme = tag.globals.theme
      # site.stylesheet_link(tag.attr['name'], tag.globals.mode, { :theme => theme })

      doc_root = tag.globals.context.server.config[:DocumentRoot]
      output = ""
      if tag.attr['name'].split(',').length > 0
        tag.attr['name'].split(',').each do |t|
          name = t.strip
          output << self.build_css_tag(name,tag)
        end
      else
        output << self.build_css_tag(tag.attr['name'],tag)
      end
      output
    end

    tag 'stylesheet_url' do |tag|
      doc_root = tag.globals.context.server.config[:DocumentRoot]

      if doc_root.split('/').last == "cleanslate_themes"
        url = "/#{tag.globals.context.request.path.split('/')[1]}/stylesheets/#{tag.attr['name']}.css"
      else
        url = "/stylesheets/#{tag.attr['name']}.css"
      end
      url
    end

    tag 'include_javascript' do |tag|
      # site = tag.globals.site
      # theme = tag.globals.theme
      # site.javascript_link(tag.attr['name'], tag.globals.mode, { :theme => theme })

      output = ""

      options = {
        async: tag.attr['async'] == "true" ? true : false,
        defer: tag.attr['defer'] == "true" ? true : false,
        type: 'text/javascript'
      }

      if tag.attr['name'].split(',').length > 0
        tag.attr['name'].split(',').each do |t|
          name = t.strip
          output << self.build_js_tag(name,tag,options)
        end
      else
        output << self.build_js_tag(tag.attr['name'],options)
      end

      output
    end

    tag 'image_url' do |tag|
      doc_root = tag.context.globals.context.server.config[:DocumentRoot]
      if doc_root.split('/').last == "cleanslate_themes"
        url = "/#{tag.context.globals.context.request.path.split('/')[1]}/images/#{tag.attr['name']}"
      else
        url = "/images/#{tag.attr['name']}"
      end
    end

    def self.build_css_tag(name, context)
      doc_root = context.globals.context.server.config[:DocumentRoot]

      if doc_root.split('/').last == "cleanslate_themes"
        url = "/#{context.globals.context.request.path.split('/')[1]}/stylesheets/#{name}.css"
      else
        url = "/stylesheets/#{name}.css"
      end

      %{<link rel="stylesheet" href="#{url}" type="text/css" />}
    end

    def self.build_js_tag(name, context, options)
      doc_root = context.globals.context.server.config[:DocumentRoot]

      if doc_root.split('/').last == "cleanslate_themes"
        url = "/#{context.globals.context.request.path.split('/')[1]}/javascripts/#{name}.js"
      else
        url = "/javascripts/#{name}.js"
      end

      options[:src] = url

      content_tag(:script, nil, options)

    end

    def self.content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
       if block_given?
         options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
         content_tag_string(name, capture(&block), options, escape)
       else
         content_tag_string(name, content_or_options_with_block, options, escape)
       end
     end

     def self.content_tag_string(name, content, options, escape = true)
        tag_options = tag_options(options, escape) if options
        content     = ERB::Util.h(content) if escape
        "<#{name}#{tag_options}>#{PRE_CONTENT_STRINGS[name.to_sym]}#{content}</#{name}>".html_safe
     end

     def self.tag_options(options, escape = true)
      return if options.blank?
      attrs = []
      options.each_pair do |key, value|
        if key.to_s == 'data' && value.is_a?(Hash)
          value.each_pair do |k, v|
            attrs << data_tag_option(k, v, escape)
          end
        elsif BOOLEAN_ATTRIBUTES.include?(key)
          attrs << boolean_tag_option(key) if value
        elsif !value.nil?
          attrs << tag_option(key, value, escape)
        end
      end
      " #{attrs.sort! * ' '}" unless attrs.empty?
      end

      def self.tag_option(key, value, escape)
        value = value.join(" ") if value.is_a?(Array)
        value = ERB::Util.h(value) if escape
        %(#{key}="#{value}")
      end

      def self.boolean_tag_option(key)
        %(#{key}="#{key}")
      end

  end
end
