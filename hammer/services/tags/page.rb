module Tags
  class Page < TagContainer

    # Page tags
    tag 'page_name' do |tag|
      tag.locals.page ||= tag.globals.context.data['page']
      if tag.locals.page['name']
        tag.locals.page['name']
      else
        Hammer.key_missing "name", {parent_key: "page"}
      end
    end

    tag 'root' do |tag|
      tag.locals.page ||= tag.globals.context.data['page']
      tag.expand
    end

    # Reset the page context to the current (global) page.
    tag 'current_page' do |tag|
      tag.expand
    end

    tag 'if_current_page' do |tag|
      tag.expand
    end

    tag 'unless_current_page' do |tag|
      tag.expand
    end

    tag 'parent' do |tag|
      tag.expand
    end

    tag 'if_parent' do |tag|
      tag.expand
    end

    tag 'unless_parent' do |tag|
      tag.expand
    end

    tag 'previous_sibling' do |tag|
      tag.expand
    end

    tag 'next_sibling' do |tag|
      tag.expand
    end

    tag 'if_children' do |tag|
      tag.expand
    end

    tag 'if_childless' do |tag|
      tag.expand
    end

    tag 'if_has_siblings' do |tag|
      tag.expand
    end

    tag 'if_only_child' do |tag|
      tag.expand
    end

    tag 'if_ancestor' do |tag|
      tag.expand
    end

    tag 'if_page_depth_eq' do |tag|
      allowed_options = %w(page_depth)
      options = tag.attr.select { |k,v| allowed_options.include?(k) }

      if tag.globals.context.data['if_page_depth_eq']
        tag.expand if options['page_depth'].to_i.abs === tag.globals.context.data['if_page_depth_eq']
      else
        Hammer.key_missing 'if_page_depth_eq', {message: "tag expanded anyways"}
        tag.expand
      end
    end

    tag 'if_page_depth_gt' do |tag|
      allowed_options = %w(page_depth)
      options = tag.attr.select { |k,v| allowed_options.include?(k) }

      if tag.globals.context.data['if_page_depth_gt']
        tag.expand if options['page_depth'].to_i.abs < tag.globals.context.data['if_page_depth_gt']
      else
        Hammer.key_missing 'if_page_depth_gt', {message: "tag expanded anyways"}
        tag.expand
      end

    end

    tag 'unless_ancestor' do |tag|
      tag.expand
    end

    tag 'get_page' do |tag|

      if tag.globals.context.data['pages']
        if tag.globals.context.data['pages'].find { |h| h['id'] == tag.attr['id'].to_i }
          tag.locals.page = tag.globals.context.data['pages'].find { |h| h['id'] == tag.attr['id'].to_i }
          tag.expand
        else
          Hammer.error "There is no page with the id: <em>#{tag.attr['id']}</em> in the mock_data.yml "
        end
      else
        Hammer.key_missing "pages"
      end

    end

    tag 'page' do |tag|
      # tag.locals.page ||= decorated_page(tag.globals.page)
      if tag.globals.context.data['page']
        tag.locals.page ||= tag.globals.context.data['page']
      else
        Hammer.key_missing "page"
      end
      tag.expand
    end

    tag 'page:if_site_default' do |tag|
      unless tag.locals.page['default_page'].nil?
        if tag.locals.page['default_page'] == true
          tag.expand
        end
      else
        Hammer.key_missing "default_page", {parent_key: "page"}
      end
    end

    # Expands the content of the tag if the current (local) page is NOT the current (global) site's
    # default page.
    tag 'page:unless_site_default' do |tag|
      unless tag.locals.page['default_page'].nil?
        if tag.locals.page['default_page'] == false
          tag.expand
        end
      else
        Hammer.key_missing "default_page", {parent_key: "page"}
      end
    end

    [:id, :name, :path, :slug, :meta_description, :title, :alternate_name, :depth].each do |attr|

      tag "page:#{attr.to_s}" do |tag|
        # tag.locals.page.send(attr)
        if tag.locals.page[attr.to_s]
          tag.locals.page[attr.to_s]
        else
          Hammer.key_missing attr, {parent_key: "page"}
        end
      end
    end

    [:created_at, :updated_at, :published_at].each do |attr|
      tag "page:#{attr.to_s}" do |tag|
        # tag.locals.page.send(attr)
        #{"}fix page:#{attr.to_s} tag"

        if tag.locals.page[attr.to_s]
          tag.locals.page[attr.to_s]
        else
          content = []
          content << (Hammer.key_missing attr.to_s, {parent_key: "page", message: "auto-generated date inserted below", comment: true, warning: true})
          content << Random.rand(11).to_s+ " days ago"
          content.join("")
        end
      end
    end

    tag 'page:url' do |tag|
      if tag.locals.page['url']
        tag.locals.page['url']
      else
        # TODO: Figure out how to inject error messages as DOM based, if in pure HTML its fine, but in an attribute it breaks
        # Hammer.key_missing 'url', {parent_key: "page", message: "auto-generated url inserted below"}
        tag.context.globals.context.request.path
      end
    end

    # Retrieve an attribute from the current page.
    tag 'page:attr' do |tag|
      # attr = tag.attr['name']
      # page = tag.locals.page
      # page.send(attr) if page.radius_attributes.include?(attr)

      attr = tag.attr['name']
      if tag.locals.page[attr.to_s]
        tag.locals.page[attr.to_s]
      else
        Hammer.key_missing attr, {parent_key: "page"}
      end
    end

    # Retrieve an attribute from the custom_data for the page.
    tag 'page:data' do |tag|
      # attr = tag.attr['name']
      #page = tag.locals.page
      #(page.custom_data || {})[attr] || "ERROR: Custom data for '#{attr}' does not exist."

      attr = tag.attr['name']
      if tag.locals.page['data'] && tag.locals.page['data'][attr.to_s]
        tag.locals.page['data'][attr.to_s]
      else
        Hammer.key_missing attr, {parent_key: "page:data"}
      end
    end


    #Fake a url for editing a page
    tag 'page:edit_url' do |tag|
      if tag.locals.page['edit_url']
        tag.locals.page['edit_url']
      else
        Hammer.key_missing "edit_url", {parent_key: "page"}
      end
    end

    # Retrieve the value of the first attribute, from the list of comma separated attributes given in the 'names' tag attribute, that has does not have a blank value.
    tag 'page:first_non_blank_attr' do |tag|
      attrs = (tag.attr['names'] || '').split(',').map{ |a| a.strip.to_sym }
      attr = self.first_present_attribute(attrs.select{ |attr| tag.locals.page.include?(attr.to_s) }.uniq)
      tag.locals.page[attr.to_s]
    end

    tag 'page:content' do |tag|
      rname = tag.attr['name'].strip
      if tag.locals.page[:content]
        if tag.locals.page[:content][rname]
          tag.locals.page[:content][rname]
        else
          Hammer.key_missing rname, {parent_key: "page:content"}
        end
      else
        Hammer.key_missing "content", {parent_key: "page"}
      end

    end

    # Expands tag if current page editable region has content
    tag 'page:if_has_content_for' do |tag|
      rname = tag.attr['region'].strip
      always = tag.attr['always_show_in_edit_mode'].to_s.to_b && tag.globals.context.data['edit_mode'] == true
      content = nil
      if tag.locals.page
        if tag.locals.page['content']
          if tag.locals.page['content'][rname]
            content =  tag.locals.page['content'][rname]
            tag.expand if always || !content.nil?
          else
            Hammer.key_missing rname, {parent_key: 'page:content'}
          end
        else
          Hammer.key_missing 'content', {parent_key: 'page'}
        end
      else
        Hammer.key_missing "page"
      end
    end

    tag 'page:unless_has_content_for' do |tag|
      rname = tag.attr['region'].strip
      always = tag.attr['always_show_in_edit_mode'].to_s.to_b && tag.globals.context.data['edit_mode'] == true
      content = nil
      if tag.locals.page
        if tag.locals.page['content']
          if tag.locals.page['content'][rname]
            content = tag.locals.page['content'][rname]
            tag.expand if always || !content.empty?
          else
            Hammer.key_missing rname, {parent_key: 'page:content'}
          end
        else
          Hammer.key_missing "content", {parent_key: "page"}
        end
      else
        Hammer.key_missing "page"
      end
    end

    # Page template tags
    tag 'page:template' do |tag|
      tag.expand
    end

    tag 'page:template:name' do |tag|
      File.basename(tag.context.globals.context.request.path, ".*")
    end


    # Page tree navigation tags
    [:descendants, :ancestors, :children, :siblings].each do |method|

      tag method.to_s do |tag|
        tag.expand
      end

      tag "#{method.to_s}:count" do |tag|
        if tag.globals.context.data['pages']
          tag.globals.context.data["pages"].count > 0
        else
          Hammer.key_missing "pages"
        end

      end

      tag "#{method.to_s}:each" do |tag|
        if tag.locals.context.data['pages']
          loop_over tag, tag.locals.context.data['pages']
        else
          Hammer.key_missing "pages"
        end
      end
    end

    tag 'get_ancestor' do |tag|
      # level = (tag.attr['level'] || 1).to_i
      # id = tag.locals.page.ancestor_ids[level]
      # page = tag.globals.site.pages.find(id) rescue nil
      #
      # unless page.present?
      #   "Could not find the given page."
      # else
      #   tag.locals.page = decorated_page(page)
      #   tag.expand
      # end
      "fix get_ancestor tag"
      Hammer.error "get_ancestor tag is not yet implemented"
    end

    def self.decorated_page(page)
      # unless page.is_a? ApplicationDecorator
      #   PageDecorator.decorate(page)
      # end
    end

    def self.find_with_options(tag, target)
      # conditions = tag.attr.symbolize_keys

      # filter = {
      #   :published => tag.globals.mode == Slate::ViewModes::VIEW, # Always limit to published pages in the public view.
      #   :name => conditions[:name],
      #   :types => conditions[:types] || [],
      #   :template => conditions[:with_template],
      #   :tags => conditions[:labels] || [],
      #   :tags_op => conditions[:labels_match] || 'any',
      #   :order => conditions[:by] || 'sort_order ASC, id',
      #   :reverse_order => conditions[:order] == 'desc' ? '1' : '0'
      #   #:page => conditions[:page].present? ? conditions[:page] : 1,
      #   #:limit => conditions[:per_page].present? ? conditions[:per_page] : 50
      # }

      # pages = Filter::Pages.new(target, filter).all
    end

    def self.count_items(tag, target)
      items = find_with_options(tag, target)
      items.reorder(nil).count # Order is irrelevant for counting
    end

    def self.loop_over(tag, target)
      if tag.attributes
        if tag.attributes['tags'] && !tag.attributes['tags'].empty?
          tags = tag.attributes['tags'].split(',').collect{|x| x.strip }
          tagged_items = []

          if tag.attributes['tags_op'] && tag.attributes['tags_op'] == 'none'
            reverse = true
          end

          target.each do |page|
            page_tags = page[:tags] || []
            page_tags = page_tags.collect{|x| x.strip }
            if page_tags
              if reverse
                if (tags & page_tags).empty?
                  tagged_items << page
                end
              else
                unless (tags & page_tags).empty?
                  tagged_items << page
                end
              end
            end
          end
          target = tagged_items
        end

        if tag.attributes['limit']
          limit = tag.attributes['limit'].to_i - 1
          items = target[0..limit]
        else
          items = target
        end
      else
        items = target
      end

      output = []
      items.each_with_index do |item, index|
        tag.locals.page = item
        tag.locals.article = item
        output << tag.expand
      end
      output.flatten.join('')
    end

    def self.first_present_attribute(*attrs)
      attrs ||= []
      attrs = [attrs] unless attrs.is_a?(Array)
      values = attrs.flatten.map { |attr| attr.to_s }.reject(&:blank?).first
    end

  end

  module Basic1
    class << self
      def tag_page_title(tag)
        page = tag.globals.page
        page.title.present? ? page.title : page.name
      end
    end
  end
end
