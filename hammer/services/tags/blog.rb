module Tags  
  class Blog < TagContainer
    
    tag 'blog' do |tag|
      # tag.locals.blog ||= load_blog(tag)
      # tag.expand
      Hammer.error "blog tag is not implemented yet"
    end
    
    tag 'article' do |tag|
      # tag.locals.article ||= load_article(tag)
      # tag.expand
      Hammer.error "article tag is not implemented yet"
    end
    
    tag 'article:id' do |tag|
      # tag.locals.article.id
      Hammer.error "rticle id tag is not implemented yet"
    end
    
    tag 'article:name' do |tag|
      # tag.locals.article.name
      Hammer.error "article name tag is not implemented yet"
    end
    
    tag 'article:title' do |tag|
      # tag.locals.article.title
      Hammer.error "article title tag is not implemented yet"
    end
    
    tag 'article:path' do |tag|
      # tag.render 'page:url', tag.attr
      Hammer.error "article path tag is not implemented yet"
    end
    
    tag 'article:content' do |tag|
      # tag.render 'page:content', tag.attr
      Hammer.error "article content tag is not implemented yet"
    end
    
    # TODO: Use a different taggable attribute, such as 'tags', instead of 'labels'. 
    #       I think labels should be used for admin purposes and 'tags' should be used
    #       for the public.
    tag 'article:tags' do |tag|
      # tag.locals.article.label_list.join(',')
      Hammer.error "article tags tag is not implemented yet"
    end
    
    tag 'article:published_at' do |tag|
      # tag.locals.article.published_at
      Hammer.error "article published_at tag is not implemented yet"
    end
            
    tag 'articles' do |tag|
      # tag.locals.articles = filter_articles(tag, tag.locals.blog.children.published)
      # tag.expand
      Hammer.error "articles tag is not implemented yet"
    end
    
    tag 'articles:each' do |tag|
      # loop_over tag, tag.locals.articles
      Hammer.error "articles:each tag is not implemented yet"
    end
    
    tag 'articles:count' do |tag|
      # count_items tag, tag.locals.articles
      Hammer.error "articles:count tag is not implemented yet"
    end
    
    tag 'articles:if_articles' do |tag|
      # cnt = tag.locals.articles.try(:all).try(:count)
      # tag.expand if cnt > 0
      Hammer.error "articles:if_articles tag is not implemented yet"
    end
    
    tag 'articles:if_no_articles' do |tag|
      # cnt = tag.locals.articles.try(:all).try(:count)
      # tag.expand if cnt.nil? or cnt == 0
      Hammer.error "articles:if_no_articles tag is not implemented yet"
    end
    
    tag 'articles:pagination' do |tag|
      # ar = tag.locals.articles.all
      # data = if ar.respond_to?(:current_page)
      #   {
      #     param: tag.attr['param'] || 'page',
      #     current: ar.current_page,
      #     previous: (ar.first_page? ? nil : ar.current_page - 1),
      #     next: (ar.last_page? ? nil : ar.current_page + 1),
      #     total: ar.total_pages
      #   }
      # else
      #   {}
      # end
      # tag.locals.article_pagination = data
      # tag.expand if data[:total] > 1
      Hammer.error "articles:pagination tag is not implemented yet"
    end
    
    tag 'articles:pagination:previous_url' do |tag|
      # url_for_page(tag, :previous)
      Hammer.error " article:pagination:previous_url tag is not implemented yet"
    end
    
    tag 'articles:pagination:next_url' do |tag|
      # url_for_page(tag, :next)
      Hammer.error "article:pagination:next_url tag is not implemented yet"
    end
    
    tag 'articles:pagination:if_first_page' do |tag|
      # return unless tag.locals.article_pagination.present?
      # tag.expand if tag.locals.article_pagination[:previous].nil?
      Hammer.error "article:pagination:if_first_page tag is not implemented yet"
    end
    
    tag 'articles:pagination:if_last_page' do |tag|
      # return unless tag.locals.article_pagination.present?
      # tag.expand if tag.locals.article_pagination[:next].nil?
      Hammer.error "article:pagination:if_last_page tag is not implemented yet"
    end
    
    class << self
      def load_blog(tag)
        page = tag.globals.page
      
        if page.type == 'ArticlePage'
          page = page.parent
        elsif page.type != 'BlogPage'
          page = nil
        end
      
        decorated_page(page)
      end
      
      def load_article(tag)
        page = tag.globals.page
        page.type == 'ArticlePage' ? decorated_page(page) : nil
      end
    
      def decorated_page(page)
        page.decorated? ? page : PageDecorator.decorate(page)
      end
    
      def filter_articles(tag, target)
        # Only allow filtering once
        return target if tag.attr.empty? || target.is_a?(Filter::Articles)
        Filter::Articles.new(target, tag.attr.symbolize_keys)
      end
    
      def count_items(tag, target)
        filter_articles(tag, target).total_count
      end
    
      def loop_over(tag, target)
        items = filter_articles(tag, target).all
        
        output = []
      
        items.each_with_index do |item, index|
          page = decorated_page item
          tag.locals.page = page
          tag.locals.article = page
          output << tag.expand
        end
      
        output.flatten.join('')
      end
      
      def url_for_page(tag, key)
        url = tag.globals.page.request_path
        data = tag.locals.article_pagination
        return nil if data.empty?
        new_val = data[key.to_sym]
        
        seo_regex = /\/#{data[:param]}\/(\d+)/
        qstring_regex = /&?#{data[:param]}=(\d+)/
        
        replace = lambda { |m| m.gsub($1, new_val.to_s) }
        
        # Replace the page number for both /page/1 and ?page=1 param styles.
        url = url.gsub(seo_regex, &replace)
        url = url.gsub(qstring_regex, &replace)
        
        # Add the page data to the URL, if it's not already there.
        unless url =~ seo_regex
          url = url.gsub(/^([^\?]+)(?:\?(.*))?$/, "\\1/#{data[:param]}/#{new_val.to_s}?\\2")
        end
        
        new_val.present? ? url : '#'
      end
    end
  end
end