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
      "fix include_javascript tag"
    end
    
    tag 'image_url' do |tag|
      # site = tag.globals.site
      # theme = tag.globals.theme
      # site.image_url(tag.attr['name'], tag.globals.mode, { :theme => theme })
      "fix image_url tag"
    end
  end
end