require 'active_support/core_ext/string/output_safety'
require_relative "../tag_container.rb"

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
      end
    end

    tag 'file:filename' do |tag|
      tag.locals.asset[:filename]
    end

    tag 'file:download_url' do |tag|
      tag.locals.asset[:download_url]
    end

    tag 'file:image_url' do |tag|
      tag.locals.asset[:image_url]

    end

    tag 'file:image_tag' do |tag|
      asset = tag.locals.asset
      size = tag.attr['size']
      options = {}

      %w(id class alt title).each do |opt|
        options[opt.to_sym] = tag.attr[opt] if tag.attr.has_key?(opt)
      end

      options[:alt] ||= asset[:alt_text]

      content_tag :img, {
          src: asset[:image_url],
          id: options[:id],
          class: options[:class],
          alt: options[:alt],
          title: options[:title]
      }
    end

    tag 'files' do |tag|
      if tag.globals.context.data['files']
        tag.expand
      else
        Hammer.key_missing "files"
      end
    end

    tag 'files:count' do |tag|
      tag.globals.context.data['files'].count
    end

    tag 'files:each' do |tag|
      loop_over tag, tag.globals.context.data['files']
    end

    def self.decorated_asset(asset)
      # unless asset.is_a? ApplicationDecorator
      #   AssetDecorator.decorate(asset)
      # end
    end

    def self.find_with_options(tag, target)
      conditions = tag.attr.symbolize_keys

      filter = {
        title: conditions[:title],
        types: conditions[:types] || [],
        tags: conditions[:labels] || [],
        tags_op: conditions[:labels_match] || 'any',
        order: conditions[:by] || 'name',
        reverse_order: conditions[:order] == 'desc' ? '1' : '0',
        random: conditions[:random].to_s.to_b,
        page: conditions[:offset].present? ? conditions[:offset].to_i : 1,
        limit: conditions[:limit].present? ? conditions[:limit].to_i : 50
      }

      # assets = Filter::Assets.new(target, filter).all
    end

    def self.count_items(tag, target)
      # items = find_with_options(tag, target)
      # items.reorder(nil).count # Order is irrelevant for counting
    end

    def self.loop_over(tag, target, out=true)

      items = target
      if tag.attr['labels']
        items = items.select{|h| h[:label] == tag.attr['labels']}
      end

      if tag.attr['limit']
        limit = tag.attr['limit'].to_i - 1
        items = items[0..limit]
      end

      if out
        output = []
        items.each do |item, index|
          # tag.locals.asset = decorated_asset item
          tag.locals.asset = item
          output << tag.expand
        end
        output.flatten.join('')
      else
        items
      end
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
