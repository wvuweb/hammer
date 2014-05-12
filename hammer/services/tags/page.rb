module Tags  
  class Page < TagContainer

    # Page tags
    tag 'page_name' do |tag|
      # tag.globals.page.name
      Faker::Lorem.word
    end
    
    tag 'root' do |tag|
      # tag.locals.page = tag.globals.site.root_page
      # tag.expand
      "fix root tag"
    end
    
    # Reset the page context to the current (global) page.
    tag 'current_page' do |tag|
      # tag.locals.page = tag.globals.page
      # tag.expand
      "fix current_page"
    end
    
    tag 'if_current_page' do |tag|
      # tag.expand if tag.locals.page.id === tag.globals.page.id
      "fix if_current_page"
    end
    
    tag 'unless_current_page' do |tag|
      # tag.expand if tag.locals.page.id != tag.globals.page.id
      "fix unless_current_page"
    end
    
    tag 'parent' do |tag|
      # tag.locals.page = decorated_page tag.locals.page.parent
      # tag.expand
      "fix parent"
    end
    
    tag 'if_parent' do |tag|
      # parent = tag.locals.page.parent
      # tag.expand if parent && !parent.root?
      false
    end
    
    tag 'unless_parent' do |tag|
      # parent = tag.locals.page.parent
      # tag.expand unless parent && !parent.root?
      "fix unless_parent tag"
    end
    
    tag 'if_children' do |tag|
      # tag.expand if tag.locals.page.has_children?
      "fix if_children tag"
    end
    
    tag 'if_childless' do |tag|
      # tag.expand if tag.locals.page.is_childless?
      "fix if_childless tag"
    end
    
    tag 'if_has_siblings' do |tag|
      # tag.expand if tag.locals.page.has_siblings?
      "fix if_has_siblings tag"
    end
    
    tag 'if_only_child' do |tag|
      # tag.expand if tag.locals.page.is_only_child?
      "fix if_only_child tag"
    end
    
    tag 'if_ancestor' do |tag|
      # tag.expand if (tag.globals.page.ancestor_ids + [tag.globals.page.id]).include?(tag.locals.page.id)
      "fix if_ancestor tag"
    end
    
    tag 'if_page_depth_eq' do |tag|
      # allowed_options = %w(page_depth)
      # options = tag.attr.select { |k,v| allowed_options.include?(k) }
      # tag.expand if options['page_depth'].to_i.abs === tag.globals.page.depth
      "fix if_page_depth_eq tag"
    end
    
    tag 'if_page_depth_gt' do |tag|
      # allowed_options = %w(page_depth)
      # options = tag.attr.select { |k,v| allowed_options.include?(k) }
      # tag.expand if tag.globals.page.depth > options['page_depth'].to_i.abs 
      "fix if_page_depth_gt tag"
    end
    
    tag 'unless_ancestor' do |tag|
      # tag.expand unless (tag.globals.page.ancestor_ids + [tag.globals.page.id]).include?(tag.locals.page.id)
      "fix unless_ancestor tag"
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
      "fix get_page tag"
    end
    
    tag 'page' do |tag|
      # tag.locals.page ||= decorated_page(tag.globals.page)
      # tag.expand
      "fix page tag"
    end
    
    [:id, :name, :path, :slug, :meta_description, :title, :alternate_name, :depth].each do |attr|
      # tag "page:#{attr.to_s}" do |tag|
      #   tag.locals.page.send(attr)
      # end
      "fix page:#{attr.to_s} tag"
    end
    
    tag 'page:url' do |tag|
      # format = tag.attr['format'].to_s.strip
      # format = nil if format.downcase =~ /\Ahtml?\Z/ 
      # # No need to append HTML or HTM to URLs since HTML is the default.
      # 
      # url = tag.locals.page.url(tag.globals.mode)
      # url << ".#{format}" if format.present?
      # url
      "fix page:url tag"
    end
    
    # Retrieve an attribute from the current page.
    tag 'page:attr' do |tag|
      # attr = tag.attr['name'].to_sym
      # page = tag.locals.page
      # page.send(attr) if page.radius_attributes.include?(attr)
      "fix page:attr tag"
    end
    
    # Retrieve the value of the first attribute, from the list of comma separated attributes given in the 'names' tag attribute, that has does not have a blank value.
    tag 'page:first_non_blank_attr' do |tag|
      attrs = (tag.attr['names'] || '').split(',').map{ |a| a.strip.to_sym }
      page = tag.locals.page
      page.first_present_attribute(attrs.select{ |attr| page.radius_attributes.include?(attr) }.uniq)
      "fix page:first_non_blank_attr tag"
    end
    
    tag 'page:content' do |tag|
      # rname = tag.attr['name'].strip
      # page = tag.locals.page
      # 
      # page.content_hash(tag.globals.mode)[rname]
      "fix page:content tag"
    end
    
    # Page template tags
    tag 'page:template' do |tag|
      # tag.locals.page_template = tag.locals.page.template
      # tag.expand
      "fix page:template tag"
    end
    
    tag 'page:template:name' do |tag|
      # tag.locals.page_template.name
      "fix page:template:name tag"
    end
    
    
    # Page tree navigation tags
    [:descendants, :ancestors, :children, :siblings].each do |method|
      tag method.to_s do |tag|
        # tag.locals.send("#{method.to_s}=", find_with_options(tag, tag.locals.page.send(method)))
        # tag.expand
        "fix #{method.to_s} tag"
      end
      
      tag "#{method.to_s}:count" do |tag| 
        # count_items tag, tag.locals.send(method)
        "fix #{method.to_s}:count tag"
      end
      
      tag "#{method.to_s}:each" do |tag| 
        # loop_over tag, tag.locals.send(method)
        "fix #{method.to_s}:each tag"
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
    end
    
    def self.decorated_page(page)
      unless page.is_a? ApplicationDecorator
        PageDecorator.decorate(page)
      end
    end
    
    def self.find_with_options(tag, target)
      conditions = tag.attr.symbolize_keys
      
      filter = {
        :published => tag.globals.mode == Slate::ViewModes::VIEW, # Always limit to published pages in the public view.
        :name => conditions[:name],
        :types => conditions[:types] || [],
        :template => conditions[:with_template],
        :tags => conditions[:labels] || [],
        :tags_op => conditions[:labels_match] || 'any',
        :order => conditions[:by] || 'sort_order ASC, id',
        :reverse_order => conditions[:order] == 'desc' ? '1' : '0'
        #:page => conditions[:page].present? ? conditions[:page] : 1,
        #:limit => conditions[:per_page].present? ? conditions[:per_page] : 50
      }
      
      pages = Filter::Pages.new(target, filter).all
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

# module Tags  
#   class Page < TagContainer
# 
#     # Page tags
#     tag 'page_name' do |tag|
#       # tag.globals.page.name
#       "fix page_name tag"
#     end
#     
#     tag 'root' do |tag|
#       # tag.locals.page = tag.globals.site.root_page
#       # tag.expand
#       "fix root tag"
#     end
#     
#     # Reset the page context to the current (global) page.
#     tag 'current_page' do |tag|
#       # tag.locals.page = tag.globals.page
#       # tag.expand
#       "fix current_page tag"
#     end
#     
#     tag 'if_current_page' do |tag|
#       # tag.expand if tag.locals.page.id === tag.globals.page.id
#       "fix if_current_page"
#     end
#     
#     tag 'unless_current_page' do |tag|
#       # tag.expand if tag.locals.page.id != tag.globals.page.id
#       "fix unless_current_page tag"
#     end
#     
#     tag 'parent' do |tag|
#       # tag.locals.page = decorated_page tag.locals.page.parent
#       # tag.expand
#       "fix parent tag"
#     end
#     
#     tag 'if_parent' do |tag|
#       # parent = tag.locals.page.parent
#       # tag.expand if parent && !parent.root?
#       "fix if_parent tag"
#     end
#     
#     tag 'unless_parent' do |tag|
#       # parent = tag.locals.page.parent
#       # tag.expand unless parent && !parent.root?
#       "fix unless_parent tag"
#     end
#     
#     tag 'if_children' do |tag|
#       # tag.expand if tag.locals.page.has_children?
#       "fix if_children tag"
#     end
#     
#     tag 'if_childless' do |tag|
#       # tag.expand if tag.locals.page.is_childless?
#       "fix if_childless tag"
#     end
#     
#     tag 'if_has_siblings' do |tag|
#       # tag.expand if tag.locals.page.has_siblings?
#       "fix if_has_siblings"
#     end
#     
#     tag 'if_only_child' do |tag|
#       # tag.expand if tag.locals.page.is_only_child?
#       "fix if_only_child"
#     end
#     
#     tag 'if_ancestor' do |tag|
#       # tag.expand if (tag.globals.page.ancestor_ids + [tag.globals.page.id]).include?(tag.locals.page.id)
#       "fix if_ancestor tag"
#     end
#     
#     tag 'if_page_depth_eq' do |tag|
#       # allowed_options = %w(page_depth)
#       # options = tag.attr.select { |k,v| allowed_options.include?(k) }
#       # tag.expand if options['page_depth'].to_i.abs === tag.globals.page.depth
#       "fix if_page_depth_eq"
#     end
#     
#     tag 'if_page_depth_gt' do |tag|
#       # allowed_options = %w(page_depth)
#       # options = tag.attr.select { |k,v| allowed_options.include?(k) }
#       # tag.expand if tag.globals.page.depth > options['page_depth'].to_i.abs 
#       "fix if_page_depth_gt tag"
#     end
#     
#     tag 'unless_ancestor' do |tag|
#       # tag.expand unless (tag.globals.page.ancestor_ids + [tag.globals.page.id]).include?(tag.locals.page.id)
#       "fix unless_ancestor tag"
#     end
#     
#     tag 'page' do |tag|
#       # tag.locals.page ||= decorated_page(tag.globals.page)
#       # tag.expand
#       "fix page tag"
#     end
#     
#     [:id, :name, :path, :slug, :meta_description, :title, :alternate_name, :depth].each do |attr|
#       tag "page:#{attr.to_s}" do |tag|
#         # tag.locals.page.send(attr)
#         "fix page#{attr.to_s} tag"
#       end
#     end
#     
#     tag 'page:url' do |tag|
#       # tag.locals.page.url(tag.globals.mode)
#       "fix page:url tag"
#     end
#     
#     # Retrieve an attribute from the current page.
#     tag 'page:attr' do |tag|
#       # attr = tag.attr['name'].to_sym
#       # page = tag.locals.page
#       # page.send(attr) if page.radius_attributes.include?(attr)
#       "fix page:attr tag"
#     end
#     
#     # Retrieve the value of the first attribute, from the list of comma separated attributes given in the 'names' tag attribute, that has does not have a blank value.
#     tag 'page:first_non_blank_attr' do |tag|
#       # attrs = (tag.attr['names'] || '').split(',').map{ |a| a.strip.to_sym }
#       # page = tag.locals.page
#       # page.first_present_attribute(attrs.select{ |attr| page.radius_attributes.include?(attr) }.uniq)
#       "fix page:first_non_blank_attr tag"
#     end
#     
#     tag 'page:content' do |tag|
#       # rname = tag.attr['name'].strip
#       # page = tag.locals.page
#       # 
#       # page.content_hash(tag.globals.mode)[rname]
#       "fix page:content tag"
#     end
#     
#     # Page template tags
#     tag 'page:template' do |tag|
#       # tag.locals.page_template = tag.locals.page.template
#       # tag.expand
#       "fix page:template tag"
#     end
#     
#     tag 'page:template:name' do |tag|
#       # tag.locals.page_template.name
#       "fix page:template:name tag"
#     end
#     
#     
#     # Page tree navigation tags
#     [:descendants, :ancestors, :children, :siblings].each do |method|
#       tag method.to_s do |tag|
#         # tag.locals.send("#{method.to_s}=", find_with_options(tag, tag.locals.page.send(method)))
#         # tag.expand
#         "fix #{method.to_s} tag"
#       end
#       
#       tag "#{method.to_s}:count" do |tag| 
#         # count_items tag, tag.locals.send(method)
#         "fix #{method.to_s}:count tag"
#       end
#       
#       tag "#{method.to_s}:each" do |tag| 
#         # loop_over tag, tag.locals.send(method)
#         "fix #{method.to_s}:each tag"
#       end
#     end
#     
#     def self.decorated_page(page)
#       unless page.is_a? ApplicationDecorator
#         PageDecorator.decorate(page)
#       end
#     end
#     
#     def self.find_with_options(tag, target)
#       conditions = tag.attr.symbolize_keys
#       
#       filter = {
#         :published => tag.globals.mode == Slate::ViewModes::VIEW, # Always limit to published pages in the public view.
#         :name => conditions[:name],
#         :types => conditions[:types] || [],
#         :template => conditions[:with_template],
#         :tags => conditions[:labels] || [],
#         :tags_op => conditions[:labels_match] || 'any',
#         :order => conditions[:by] || 'sort_order ASC, id',
#         :reverse_order => conditions[:order] == 'desc' ? '1' : '0'
#         #:page => conditions[:page].present? ? conditions[:page] : 1,
#         #:limit => conditions[:per_page].present? ? conditions[:per_page] : 50
#       }
#       
#       pages = Filter::Pages.new(target, filter).all
#     end
#     
#     def self.count_items(tag, target)
#       items = find_with_options(tag, target)
#       items.reorder(nil).count # Order is irrelevant for counting
#     end
#     
#     def self.loop_over(tag, target)
#       items = find_with_options(tag, target)
#       output = []
#       
#       items.each_with_index do |item, index|
#         tag.locals.child = decorated_page item
#         tag.locals.page = decorated_page item
#         output << tag.expand
#       end
#       
#       output.flatten.join('')
#     end
#   end
#   
#   module Basic1
#     class << self
#       def tag_page_title(tag)
#         page = tag.globals.page
#         page.title.present? ? page.title : page.name
#       end
#     end
#   end
# end