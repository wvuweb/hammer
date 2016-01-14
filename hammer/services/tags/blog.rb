require 'chronic'

module Tags

  # Blog Tag Module
  class Blog < TagContainer

    include ActionView::Helpers::TagHelper
    include ActionView::Context

    BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked autobuffer
                            autoplay controls loop selected hidden scoped async
                            defer reversed ismap seamless muted required
                            autofocus novalidate formnovalidate open pubdate
                            itemscope allowfullscreen default inert sortable
                            truespeed typemustmatch).to_set
    BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map{|attribute| attribute.to_sym})
    PRE_CONTENT_STRINGS = {
      textarea: "\n"
    }

    tag 'blog' do |tag|
      # tag.locals.blog ||= load_blog(tag)
      # tag.expand
      if tag.globals.context.data && tag.globals.context.data['blog']
        tag.locals.blog = tag.globals.context.data['blog']
      end
      tag.expand
    end

    tag 'article' do |tag|
      tag.locals.article ||= load_article(tag)
      tag.expand
    end

    tag 'article:id' do |tag|
      tag.locals.article['id']
    end

    tag 'article:name' do |tag|
      tag.locals.article['name']
    end

    tag 'article:title' do |tag|
      tag.locals.article['title']
    end

    tag 'article:path' do |tag|
      tag.render 'page:url', tag.attr
    end

    tag 'article:content' do |tag|
      # tag.render 'page:content', tag.attr
      # tag.locals.article['content']
      rname = tag.attr['name'].strip

      if tag.locals.article[:content] && tag.locals.article[:content][rname]
        tag.locals.article[:content][rname]
      else
        Hammer.error 'Set key <em>blog:articles:article:content</em> in mock_data file'
      end
    end

    # TODO: Use a different taggable attribute, such as 'tags', instead of 'labels'.
    #       I think labels should be used for admin purposes and 'tags' should be used
    #       for the public.
    tag 'article:tags' do |tag|
      tag.locals.article.label_list.join(',')
    end

    tag 'article:published_at' do |tag|
      tag.locals.article[:published_at]
    end

    tag 'article:author_first_name' do |tag|
      tag.locals.article[:created_by][:first_name]
    end

    tag 'article:author_last_name' do |tag|
      tag.locals.article[:created_by][:last_name]
    end

    tag 'article:author_full_name' do |tag|
      tag.locals.article[:created_by][:first_name] + ' ' + tag.locals.article[:created_by][:last_name]
    end

    tag 'articles' do |tag|
      # tag.locals.blog ||= load_blog(tag)
      # tag.locals.articles = filter_articles(tag, tag.locals.blog.children.published)
      # tag.expand

      if tag.globals.context.data && tag.globals.context.data[:blog] && tag.globals.context.data[:blog][:articles]
        tag.locals.articles = tag.globals.context.data[:blog][:articles]
      end

      tag.locals.articles = [] if tag.locals.articles.nil?

      tag.expand
    end

    tag 'articles:each' do |tag|
      loop_over tag, tag.locals.articles
    end

    tag 'articles:count' do |tag|
      count_items tag, tag.locals.articles
    end

    tag 'articles:if_articles' do |tag|
      # cnt = tag.locals.articles.try(:all).try(:count)
      # tag.expand if cnt > 0

      tag.expand if tag.locals.articles.count > 0
    end

    tag 'articles:if_no_articles' do |tag|
      # cnt = tag.locals.articles.try(:all).try(:count)
      # tag.expand if cnt.nil? or cnt == 0
      if tag.locals.articles.count.nil? or tag.locals.articles.count == 0
        tag.expand
      end
    end

    tag 'articles:pagination' do |tag|
      # ar = tag.locals.articles
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
      tag.expand
      # Hammer.error "articles:pagination tag is not implemented yet"
    end

    tag 'articles:pagination:previous_url' do |tag|
      url_for_page(tag, :previous)
    end

    tag 'articles:pagination:next_url' do |tag|
      url_for_page(tag, :next)
    end

    tag 'articles:pagination:if_first_page' do |tag|
      return unless tag.locals.article_pagination.present?
      tag.expand if tag.locals.article_pagination[:previous].nil?
    end

    tag 'articles:pagination:if_last_page' do |tag|
      return unless tag.locals.article_pagination.present?
      tag.expand if tag.locals.article_pagination[:next].nil?
    end

    tag 'archive' do |tag|
      tag.expand
    end

    tag 'archive:monthly' do |tag|
      options = gather_options(
        tag,
        {
          date_format: '%B %Y',
          ul_class: 'cs-blog-archive--monthly',
          include_count: true,
          count_class: 'cs-blog-archive__count'
        }
      )
      ActionView::Base.new.content_tag :ul, class: options[:ul_class] do

        if tag.globals.context.data[:blog][:archive] && tag.globals.context.data[:blog][:archive][:monthly] && tag.globals.context.data[:blog][:archive][:monthly].count > 0
          data = tag.globals.context.data[:blog][:archive][:monthly]
        else
          date_to = Date.parse(Chronic.parse('today').strftime("%Y-%m-%d").to_s)
          date_from = Date.parse(Chronic.parse('4 months ago').strftime("%Y-%m-%d").to_s)

          date_range = date_from..date_to
          date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq

          data = [
                  {"item"=>{"date"=>"#{date_months[0]}", "count"=>20, "url"=>"#"}},
                  {"item"=>{"date"=>"#{date_months[1]}", "count"=>14, "url"=>"#"}},
                  {"item"=>{"date"=>"#{date_months[2]}", "count"=>32, "url"=>"#"}},
                  {"item"=>{"date"=>"#{date_months[3]}", "count"=>22, "url"=>"#"}},
                  {"item"=>{"date"=>"#{date_months[4]}", "count"=>18, "url"=>"#"}}
                ].reverse
        end

        data.map do |a|
          date = parse_date(a['item']['date'])
          ActionView::Base.new.content_tag :li do
            content = "#{date.strftime(options[:date_format])}"
            content += ' ' + ActionView::Base.new.content_tag(:span, a['item']['count'], class: options[:count_class]) if options[:include_count].to_s.to_b
            ActionView::Base.new.content_tag :a, content.html_safe, href: a['item']['url']
          end
        end.join("\n").html_safe
      end
    end

    def self.parse_date(str)
      # We will try parsing the date string with Chronic first. If that doesn't work, we'll attempt to
      # parse the string with DateTime.
      Time.zone = "Eastern Time (US & Canada)"
      Chronic.time_class = Time.zone
      date = Chronic.parse(str) || DateTime.parse(str) rescue nil
    end


    class << self
      def gather_options(tag, defaults = {})
        options = defaults.symbolize_keys
        attrs = (%w(ul_id ul_class).map(&:to_sym) + defaults.keys.map(&:to_sym)).uniq

        attrs.each do |opt|
          options[opt] = tag.attr[opt.to_s] if tag.attr.has_key?(opt.to_s)
        end

        options
      end

      def load_blog(tag)
        page = if tag.attr['id'].present?
          tag.globals.site.pages.find(tag.attr['id']) rescue nil
        else
          tag.locals.page
        end

        if page.type == 'ArticlePage'
          page = page.parent
        elsif page.type != 'BlogPage'
          page = nil
        end

        decorated_page(page)
      end

      def load_article(tag)
        # page = tag.globals.page
        #page.type == 'ArticlePage' ? decorated_page(page) : nil
        if tag.globals.context.data && tag.globals.context.data['blog'] && tag.globals.context.data['blog']['articles']
          tag.globals.context.data['blog']['articles'].first
        else
          content = <<-CONTENT
            <p>#{Faker::Lorem.paragraph(2)}</p>
            <p>#{Faker::Lorem.paragraph(5)}</p>
            <p>#{Faker::Lorem.paragraph(3)}</p>
          CONTENT
          article = {
            :name => Faker::Lorem.sentence(1),
            :title => Faker::Lorem.sentence(1),
            :created_by => { :first_name => Faker::Name.first_name, :last_name =>  Faker::Name.last_name },
            :content => content,
            :published_at => Random.rand(11).to_s+ "days ago"
          }
          tag.locals.article = article
          article
        end
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
        # filter_articles(tag, target).total_count
        if tag.globals.context.data && tag.globals.context.data['blog'] && tag.globals.context.data['blog']['articles']
          tag.globals.context.data['blog']['articles'].count
        else
          5
        end
      end

      def loop_over(tag, target)
        # items = filter_articles(tag, target).all
        #
        # output = []
        #
        # items.each_with_index do |item, index|
        #   page = decorated_page item
        #   tag.locals.page = page
        #   tag.locals.article = page
        #   output << tag.expand
        # end
        #
        # output.flatten.join('')
        if tag.attr['limit']
          limit = tag.attr['limit'].to_i - 1
          items = target[0..limit]
        else
          items = target
        end

        output = []
        items.each_with_index do |item, index|
          page = item
          tag.locals.page = page
          tag.locals.article = page
          output << tag.expand
        end

        output.flatten.join('')
      end

      def url_for_page(tag, key)
        # url = tag.globals.page.request_path
        # data = tag.locals.article_pagination
        # return nil if data.empty?
        # new_val = data[key.to_sym]
        #
        # seo_regex = /\/#{data[:param]}\/(\d+)/
        # qstring_regex = /&?#{data[:param]}=(\d+)/
        #
        # replace = lambda { |m| m.gsub($1, new_val.to_s) }
        #
        # # Replace the page number for both /page/1 and ?page=1 param styles.
        # url = url.gsub(seo_regex, &replace)
        # url = url.gsub(qstring_regex, &replace)
        #
        # # Add the page data to the URL, if it's not already there.
        # unless url =~ seo_regex
        #   url = url.gsub(/^([^\?]+)(?:\?(.*))?$/, "\\1/#{data[:param]}/#{new_val.to_s}?\\2")
        # end
        #
        # new_val.present? ? url : '#'
        '#'
      end

    end

  end
end
