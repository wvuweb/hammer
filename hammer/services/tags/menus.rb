module Tags  
  class Menus < TagContainer
    tag 'site_menu' do |tag|
      # @tag = tag
      # root = PageDecorator.decorate(tag.globals.site.root_page)
      # page = tag.globals.page
      # options = gather_options(tag)
      # 
      # # TODO: Figure out the best way to cache this since the active page changes from page to page.
      # cache ['site-menu', @tag.globals.site, page, @tag.globals.mode] do
      #   render_menu_for_page(root, page, options)
      # end
      "fix site_menu tag"
    end
    
    tag 'sub_menu' do |tag|
      # @tag = tag
      # page = tag.globals.page
      # options = gather_options(tag)
      # 
      # cache ['sub-menu', @tag.globals.site, page, @tag.globals.mode] do
      #   render_menu_for_page(page, nil, options)
      # end
      "fix sub_menu tag"
    end
    
    tag 'ancestor_menu' do |tag|
      # @tag = tag
      # page = tag.globals.page
      # options = gather_options(tag, {
      #   start_depth: nil,
      #   max_depth: nil,
      #   ul_class: 'cs-generatedNav-ancestor',
      #   active_class: 'active'
      # })
      # 
      # cache ['ancestor-menu', @tag.globals.site, page, @tag.globals.mode] do
      #   start_depth = (options[:start_depth] || 1).to_i.abs
      #   max_depth = page.depth
      #   
      #   bloodline = page.ancestors.from_depth(start_depth).to_a
      #   bloodline << page.model
      #   base = bloodline.first
      #   
      #   menu = if base.depth < start_depth
      #     content_tag :ul, :id => options[:ul_id], :class => options[:ul_class] do
      #       base.children.sort_ordered.map do |item|
      #         render_ancestor_node(item, bloodline, options) if item.navigable?
      #       end.join.html_safe
      #     end
      #   else
      #     content_tag :ul, :id => options[:ul_id], :class => options[:ul_class] do
      #       base.siblings.sort_ordered.map do |item|
      #         render_ancestor_node(item, bloodline, options) if item.navigable?
      #       end.join.html_safe
      #     end
      #   end
      #   
      #   menu
      # end
      "fix ancestor_menu tag"
    end
    
    def self.gather_options(tag, defaults = {})
      options = defaults.symbolize_keys
      attrs = (%w(ul_id ul_class active_class).map(&:to_sym) + defaults.keys.map(&:to_sym)).uniq
      
      attrs.each do |opt|
        options[opt] = tag.attr[opt.to_s] if tag.attr.has_key?(opt.to_s)
      end
      
      options
    end
    
    
    def self.render_menu_for_page(page, current_page = nil, options = {})
      current_page ||= page
      mode = @tag.globals.mode
      children = page.children.navigable.includes(:current_path).to_a
      
      options.reverse_merge!({
        ul_class: 'cs-generatedNav',
        active_class: 'active'
      })
      
      return nil unless children.present?
      
      content_tag :ul, :id => options[:ul_id], :class => options[:ul_class] do
        children.map do |c|
          child = PageDecorator.decorate(c)
          
          # TODO: Fix this 'active' page logic. It doesn't work for child pages and also requires every page
          # to recache the menu because the active menu item can change from page to page.
          hclass = (child.id == current_page.id || current_page.ancestor_ids.include?(child.id)) ? options[:active_class] : nil
          
          content_tag :li, child.link_to(:mode => mode), :class => hclass
        end.join.html_safe
      end
    end
    
    def self.render_ancestor_node(node, bloodline, options = {})
      mode = @tag.globals.mode
      is_current_page = node == bloodline.last
      max_depth = options[:max_depth].to_i
      
      content_tag :li do
        content = PageDecorator.decorate(node).link_to(:mode => mode, :class => (is_current_page ? options[:active_class] : nil))
        
        if bloodline.include?(node)
          children = if max_depth <= 0 || node.depth < max_depth
            node.children.sort_ordered
          else
            []
          end
          
          content << content_tag(:ul) do
            children.map do |child|
              render_ancestor_node(child, bloodline, options)
            end.join.html_safe
          end.html_safe unless children.empty?
        end
        
        content.html_safe
      end
    end
  end
end