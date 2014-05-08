module Tags 
  class ThemeAsset < TagContainer
    
    # <r:include_stylesheet name="bootstrap, main" compress="true|false" join="true|false"
    tag 'include_stylesheet' do |tag|
      # site = tag.globals.site
      # theme = tag.globals.theme
      # site.stylesheet_link(tag.attr['name'], tag.globals.mode, { :theme => theme })
      %{<link rel="stylesheet" href="#{tag.attr['name']}" type="text/css" />}
    end
    
    tag 'include_javascript' do |tag|
      # site = tag.globals.site
      # theme = tag.globals.theme
      # site.javascript_link(tag.attr['name'], tag.globals.mode, { :theme => theme })
    end
    
    tag 'image_url' do |tag|
      # site = tag.globals.site
      # theme = tag.globals.theme
      # site.image_url(tag.attr['name'], tag.globals.mode, { :theme => theme })
    end
  end
end