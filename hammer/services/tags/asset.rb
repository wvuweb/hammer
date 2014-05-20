module Tags  
  class Asset < TagContainer
    tag 'file' do |tag|
      tag.locals.asset
      tag.expand
    end
    
    %w(id title name alt_text description).each do |mthd|
      tag "file:#{mthd}" do |tag|
        # tag.locals.asset.send(mthd.to_sym)
        Hammer.error "file:#{mthd} tag is not implemented yet"
      end
    end
    
    tag 'file:filename' do |tag|
      # tag.locals.asset.try(:filename)
      Hammer.error "file:filename tag is not implemented yet"
    end
    
    tag 'file:download_url' do |tag|
      # asset = tag.locals.asset
      # asset.public_download_url
      Hammer.error "file:download_url tag is not implemented yet"
    end
    
    # <r:files labels="foo,bar" labels_match="any|all|none" by="name|title|size|etc" order="asc|desc"/>
    tag 'files' do |tag|
      # tag.locals.assets = find_with_options(tag, tag.globals.site.assets)
      # tag.expand
      Hammer.error "files tag is not implemented yet"
    end
    
    tag 'files:count' do |tag|
      # count_items tag, tag.locals.assets
      Hammer.error "files:count tag is not implemented yet"
    end
    
    tag 'files:each' do |tag|
      # loop_over tag, tag.locals.assets
      Hammer.error "files:each tag is not implemented yet"
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
  end
end