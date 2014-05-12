module Tags 
  class ThemeAsset < TagContainer
    
    # <r:include_stylesheet name="bootstrap, main" compress="true|false" join="true|false"
    tag 'include_stylesheet' do |tag|
      # site = tag.globals.site
      # theme = tag.globals.theme
      # site.stylesheet_link(tag.attr['name'], tag.globals.mode, { :theme => theme })
      
      doc_root = tag.globals.context.server.config[:DocumentRoot]
      
      if doc_root.split('/').last == "cleanslate_themes"
        url = "/#{tag.globals.context.request.path.split('/')[1]}/stylesheets/#{tag.attr['name']}.css"
      else
        url = "/stylesheets/#{tag.attr['name']}.css"
      end
      
      %{<link rel="stylesheet" href="#{url}" type="text/css" />}
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
      # site = tag.globals.site
      # theme = tag.globals.theme
      # site.image_url(tag.attr['name'], tag.globals.mode, { :theme => theme })
      "fix image_url tag"
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