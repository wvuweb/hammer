module Tags
  class Page < TagContainer

    # Page tags
    tag 'page_name' do |tag|
      # tag.globals.page.name
      if tag.globals.context.data
        if tag.globals.context.data['page'] && tag.globals.context.data['page']['name']
          tag.globals.context.data['page']['name']
        elsif tag.globals.context.data['page_name']
          tag.globals.context.data['page_name']
        else
          Hammer.error "Add key <em>name</em> under page"
        end
      else
        "Page Name"
      end
    end

    tag 'root' do |tag|
      # tag.locals.page = tag.globals.site.root_page
      # tag.expand
      if tag.globals.context.data['root']
        tag.globals.context.data['root'] ? tag.expand : false
      end
    end

    # Reset the page context to the current (global) page.
    tag 'current_page' do |tag|
      # tag.locals.page = tag.globals.page
      # tag.expand
      # Hammer.error "current_page tag is not yet implemented"
      tag.expand
    end

    tag 'if_current_page' do |tag|
      # tag.expand if tag.locals.page.id === tag.globals.page.id
      # Hammer.error "if_current_page tag is not yet implemented"
      tag.expand
    end

    tag 'unless_current_page' do |tag|
      # tag.expand if tag.locals.page.id != tag.globals.page.id
      # Hammer.error "unless_current_page tag is not yet implemented"
      tag.expand
    end

    tag 'parent' do |tag|
      # tag.locals.page = decorated_page tag.locals.page.parent
      # tag.expand
      # Hammer.error "parent tag is not yet implemented"
      tag.expand
    end

    tag 'if_parent' do |tag|
      # parent = tag.locals.page.parent
      # tag.expand if parent && !parent.root?
      # Hammer.error "if_parent tag is not yet implemented"
      tag.expand
    end

    tag 'unless_parent' do |tag|
      # parent = tag.locals.page.parent
      # tag.expand unless parent && !parent.root?
      # Hammer.error "unless_parent tag is not yet implemented"
      tag.expand
    end

    tag 'previous_sibling' do |tag|
      # tag.locals.page = p = decorated_page(tag.locals.page.previous_sibling)
      # tag.expand if p.present?
      tag.expand
    end

    tag 'next_sibling' do |tag|
      # tag.locals.page = p = decorated_page(tag.locals.page.next_sibling)
      # tag.expand if p.present?
      tag.expand
    end

    tag 'if_children' do |tag|
      # tag.expand if tag.locals.page.has_children?
      # Hammer.error "if_children tag is not yet implemented"
      tag.expand
    end

    tag 'if_childless' do |tag|
      # tag.expand if tag.locals.page.is_childless?
      # Hammer.error "if_childless tag is not yet implemented"
      tag.expand
    end

    tag 'if_has_siblings' do |tag|
      # tag.expand if tag.locals.page.has_siblings?
      # Hammer.error "if_has_siblings tag is not yet implemented"
      tag.expand
    end

    tag 'if_only_child' do |tag|
      # tag.expand if tag.locals.page.is_only_child?
      # Hammer.error "if_only_child tag is not yet implemented"
      tag.expand
    end

    tag 'if_ancestor' do |tag|
      # tag.expand if (tag.globals.page.ancestor_ids + [tag.globals.page.id]).include?(tag.locals.page.id)
      # Hammer.error "if_ancestor tag is not yet implemented"
      tag.expand
    end

    tag 'if_page_depth_eq' do |tag|
      allowed_options = %w(page_depth)
      options = tag.attr.select { |k,v| allowed_options.include?(k) }
      # tag.expand if options['page_depth'].to_i.abs === tag.globals.page.depth

      if tag.globals.context.data && tag.globals.context.data['if_page_depth_eq']
        tag.expand if options['page_depth'].to_i.abs === tag.globals.context.data['if_page_depth_eq']
      else
        tag.expand
      end

      #"fix if_page_depth_eq tag"
    end

    tag 'if_page_depth_gt' do |tag|
      allowed_options = %w(page_depth)
      options = tag.attr.select { |k,v| allowed_options.include?(k) }
      # tag.expand if tag.globals.page.depth > options['page_depth'].to_i.abs
      if tag.globals.context.data && tag.globals.context.data['if_page_depth_eq']
        tag.expand if tag.globals.context.data['if_page_depth_gt'] > options['page_depth'].to_i.abs
      else
        tag.expand
      end

    end

    tag 'unless_ancestor' do |tag|
      # tag.expand unless (tag.globals.page.ancestor_ids + [tag.globals.page.id]).include?(tag.locals.page.id)
      # Hammer.error "unless_ancestor tag is not yet implemented"
      tag.expand
    end

    # The get_page tag allows you to retrieve a site page other than the current page and then use other
    # page related tags within it to interact with it and pull information from it.
    #
    # Example:
    #
    # <r:get_page id="1234">
    #   <r:page:name />
    # </r:get_page>
    #
    # The example above will output the name of the page with ID 1234, as long as the page exists and
    # belongs to the current site.
    tag 'get_page' do |tag|
      # page = tag.globals.site.pages.find(tag.attr['id']) rescue nil
      #
      # unless page.present?
      #   "Could not find the given page."
      # else
      #   tag.locals.page = decorated_page(page)
      #   tag.expand
      # end
      # Hammer.error "get_page tag is not yet implemented"
      # tag.expand
      if tag.globals.context.data && tag.globals.context.data['get_page']
        if tag.globals.context.data['get_page'].include?(tag.attr['id'].to_i)
          tag.expand
        else
          Hammer.error "key <em>get_page id</em> of #{tag.attr['id']} not found in mock_data file"
        end
      else
        Hammer.error "Set key <em>get_page</em> in mock_data file"
      end

    end

    tag 'page' do |tag|
      tag.locals.page ||= decorated_page(tag.globals.page)
      tag.expand
    end

    [:id, :name, :path, :slug, :meta_description, :title, :alternate_name, :depth, :created_at, :updated_at, :published_at].each do |attr|
      tag "page:#{attr.to_s}" do |tag|
        # tag.locals.page.send(attr)
        #{"}fix page:#{attr.to_s} tag"
        if tag.globals.context.data && tag.globals.context.data['page'] && tag.globals.context.data['page'][attr.to_s]
          tag.globals.context.data['page'][attr.to_s]
        else
          Hammer.error "Page Attribute missing page:#{attr}"
        end
      end
    end

    tag 'page:url' do |tag|
      # format = tag.attr['format'].to_s.strip
      # format = nil if format.downcase =~ /\Ahtml?\Z/
      # # No need to append HTML or HTM to URLs since HTML is the default.
      #
      # url = tag.locals.page.url(tag.globals.mode)
      # url << ".#{format}" if format.present?
      # url
      # Hammer.error "page:url tag is not yet implemented"
      if tag.globals.context.data && tag.globals.context.data['page'] && tag.globals.context.data['page']['url']
        tag.globals.context.data['page']['url']
      else
        tag.context.globals.context.request.path
      end
    end

    # Retrieve an attribute from the current page.
    tag 'page:attr' do |tag|
      attr = tag.attr['name']
      # page = tag.locals.page
      # page.send(attr) if page.radius_attributes.include?(attr)
      if tag.globals.context.data && tag.globals.context.data['page'][attr]
        tag.globals.context.data['page'][attr]
      else
        Hammer.error "Page Attribute missing Page:#{attr}"
      end
    end

    # Retrieve an attribute from the custom_data for the page.
    tag 'page:data' do |tag|
      attr = tag.attr['name']
      #page = tag.locals.page
      #(page.custom_data || {})[attr] || "ERROR: Custom data for '#{attr}' does not exist."

      if tag.globals.context.data && tag.globals.context.data['page'] && tag.globals.context.data['page']['data'] && tag.globals.context.data['page']['data'][attr]
        tag.globals.context.data['page']['data'][attr]
      else
        Hammer.error "Page Data attribute missing Page:data:#{attr}"
      end


    end


    #Fake a url for editing a page
    tag 'page:edit_url' do |tag|
      if tag.globals.context.data && tag.globals.context.data['page']['edit_url']
        tag.globals.context.data['page']['edit_url']
      else
        # return a hash as a url.
        "#"
      end
    end

    # Retrieve the value of the first attribute, from the list of comma separated attributes given in the 'names' tag attribute, that has does not have a blank value.
    tag 'page:first_non_blank_attr' do |tag|
      if tag.globals.context.data && tag.globals.context.data["page"]
        attrs = (tag.attr['names'] || '').split(',').map{ |a| a.strip.to_sym }
        attr = self.first_present_attribute(attrs.select{ |attr| tag.globals.context.data["page"].include?(attr.to_s) }.uniq)
        tag.globals.context.data["page"][attr]
      else
        Hammer.error "Set key <em>page</em> in mock_data file"
      end
      #binding.pry#"fix page:first_non_blank_attr tag"
    end

    tag 'page:content' do |tag|
      rname = tag.attr['name'].strip
      if tag.globals.context.data
        if tag.globals.context.data["page"] && tag.globals.context.data["page"]["content"] && tag.globals.context.data["page"]["content"][rname]
          tag.globals.context.data["page"]["content"][rname]
        else
          Hammer.error "Set key <em>page:content:#{rname}</em> in mock_data file"
        end
      end
    end

    # Expands tag if current page editable region has content
    tag 'page:if_has_content_for' do |tag|
      rname = tag.attr['region'].strip
      always = tag.attr['always_show_in_edit_mode'].to_s.to_b && tag.globals.context.data['edit_mode'] == true
      content = nil
      if tag.globals.context.data["page"] && tag.globals.context.data["page"]["content"] && tag.globals.context.data["page"]["content"][rname]
        content = tag.globals.context.data["page"]["content"][rname]
      end
      tag.expand if always || !content.nil?
    end

    tag 'page:unless_has_content_for' do |tag|
      rname = tag.attr['region'].strip
      always = tag.attr['always_show_in_edit_mode'].to_s.to_b && tag.globals.context.data['edit_mode'] == true
      content = nil
      if tag.globals.context.data["page"] && tag.globals.context.data["page"]["content"] && tag.globals.context.data["page"]["content"][rname]
        content = tag.globals.context.data["page"]["content"][rname]
      end
      tag.expand if always || content.nil?
    end

    # Page template tags
    tag 'page:template' do |tag|
      # tag.locals.page_template = tag.locals.page.template
      # tag.expand
      if tag.globals.context.data && tag.globals.context.data["page"]
        # binding.pry
        if tag.globals.context.data["page"]["template"]
          tag.locals.page_template = tag.globals.context.data["page"]["template"]
        end
      end
      tag.expand

    end

    tag 'page:template:name' do |tag|
      # tag.locals.page_template.name
      if tag.locals.page_template && tag.locals.page_template["name"]
        name = tag.locals.page_template["name"]
      else
        name = File.basename(tag.context.globals.context.request.path, ".*")
      end
      name
    end


    # Page tree navigation tags
    [:descendants, :ancestors, :children, :siblings].each do |method|
      tag method.to_s do |tag|
        # tag.locals.send("#{method.to_s}=", find_with_options(tag, tag.locals.page.send(method)))
        tag.expand
      end

      tag "#{method.to_s}:count" do |tag|
        #count_items tag, tag.locals.send(method)
        if tag.globals.context.data && tag.globals.context.data["pages"]
          tag.globals.context.data["pages"].count
        else
         Hammer.error "#{method.to_s}:count needs the 'pages' key in mock_data.yml"
        end
      end

      tag "#{method.to_s}:each" do |tag|
        #loop_over tag, tag.locals.send(method)
        if tag.globals.context.data && tag.globals.context.data["pages"]
          mock_pages = tag.globals.context.data["pages"]
          mock_pages.unshift(tag.globals.context.data["page"]) #include original page object

          output = ""
          mock_pages.each do |page|
            tag.globals.context.data["page"] = page #set the current context
            output = output + tag.expand
          end
          output
        else
         Hammer.error "#{method.to_s}:each needs the 'pages' key in mock_data.yml"
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
      items = find_with_options(tag, target)
      output = []

      items.each_with_index do |item, index|
        tag.locals.child = decorated_page item
        tag.locals.page = decorated_page item
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
