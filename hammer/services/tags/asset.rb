require 'active_support/core_ext/string/output_safety'

module Tags
  class Asset < TagContainer


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

    tag 'file' do |tag|
      tag.locals.asset
      tag.expand
    end

    %w(id title name alt_text description).each do |mthd|
      tag "file:#{mthd}" do |tag|
        tag.locals.asset[mthd.to_sym]
        #Hammer.error "file:#{mthd} tag is not implemented yet"
      end
    end

    tag 'file:filename' do |tag|
      # tag.locals.asset.try(:filename)
      asset = tag.locals.asset
      #Hammer.error "file:filename tag is not implemented yet"
      asset[:filename]
    end

    tag 'file:download_url' do |tag|
      asset = tag.locals.asset
      # asset.public_download_url
      #Hammer.error "file:download_url tag is not implemented yet"
      asset[:download_url]
    end

    tag 'file:image_url' do |tag|
      asset = tag.locals.asset
      # size = tag.attr['size']
      #
      # if asset.is_a?(ImageAsset)
      #   asset.image_url(size)
      # end
      asset[:image_url]

    end

    tag 'file:image_tag' do |tag|
      asset = tag.locals.asset
      size = tag.attr['size']
      options = {}

      %w(id class alt title).each do |opt|
        options[opt.to_sym] = tag.attr[opt] if tag.attr.has_key?(opt)
      end
      #
      # if asset.is_a?(ImageAsset)
      options[:alt] ||= asset[:alt_text]
      #   asset.image_tag(size, options)
      # end
      #Hammer.error "file:image_tag is not implemented yet"

      content_tag :img, { :src=>asset[:image_url], :id => options[:id], :class => options[:class], :alt => options[:alt], :title => options[:title]}
    end

    # <r:files labels="foo,bar" labels_match="any|all|none" by="name|title|size|etc" order="asc|desc"/>
    tag 'files' do |tag|
      # tag.locals.assets = find_with_options(tag, tag.globals.site.assets)
      # tag.expand
      if tag.globals.context.data && tag.globals.context.data['files']
        tag.expand
      end

      #Hammer.error "files tag is not implemented yet"
    end

    tag 'files:count' do |tag|
      # count_items tag, tag.locals.assets
      Hammer.error "files:count tag is not implemented yet"
    end

    tag 'files:each' do |tag|
      # loop_over tag, tag.locals.assets
      if tag.globals.context.data && tag.globals.context.data['files']
        #loop_over tag, tag.globals.context.data['files']
        files = tag.globals.context.data['files']
        output = []
        files.each do |file|
          tag.locals.asset = file
          output << tag.expand
        end

        output.flatten.join('')
      end

      #Hammer.error "files:each tag is not implemented yet"
    end

    def self.decorated_asset(asset)
      unless asset.is_a? ApplicationDecorator
        AssetDecorator.decorate(asset)
      end
    end

    def self.find_with_options(tag, target)
      conditions = tag.attr.symbolize_keys

      filter = {
        :title => conditions[:title],
        :types => conditions[:types] || [],
        :tags => conditions[:labels] || [],
        :tags_op => conditions[:labels_match] || 'any',
        :order => conditions[:by] || 'name',
        :reverse_order => conditions[:order] == 'desc' ? '1' : '0'
        #:page => conditions[:page].present? ? conditions[:page] : 1,
        #:limit => conditions[:per_page].present? ? conditions[:per_page] : 50
      }

      assets = Filter::Assets.new(target, filter).all
    end

    def self.count_items(tag, target)
      items = find_with_options(tag, target)
      items.reorder(nil).count # Order is irrelevant for counting
    end

    def self.loop_over(tag, target)
      items = find_with_options(tag, target)
      output = []

      items.each_with_index do |item, index|
        tag.locals.asset = decorated_asset item
        output << tag.expand
      end

      output.flatten.join('')
    end


    def self.content_tag(name, options = nil, open = false, escape = true)
      "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
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
