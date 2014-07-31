module Tags 
  class ThemeAsset < TagContainer
    
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
    
    tag 'include_javascript' do |tag|
      # site = tag.globals.site
      # theme = tag.globals.theme
      # site.javascript_link(tag.attr['name'], tag.globals.mode, { :theme => theme })
      
      output = ""
      if tag.attr['name'].split(',').length > 0
        tag.attr['name'].split(',').each do |t|
          name = t.strip
          output << self.build_js_tag(name,tag)
        end
      else
        output << self.build_js_tag(tag.attr['name'],tag)
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
    
    def self.build_js_tag(name, context)
      doc_root = context.globals.context.server.config[:DocumentRoot]
      
      if doc_root.split('/').last == "cleanslate_themes"
        url = "/#{context.globals.context.request.path.split('/')[1]}/javascripts/#{name}.js"
      else
        url = "/javascripts/#{name}.js"
      end
      
      %{<script src="#{url}" type="text/javascript"></script>}
      
    end
  end
end