require 'chronic'

module Tags

  # Blog Tag Module
  class Blog < TagContainer

    def initialize
      @blog = nil
    end

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
      tag.locals.blog ||= load_blog(tag)
      tag.expand
    end

    tag 'article' do |tag|
      tag.locals.article ||= load_article(tag)
      tag.expand
    end

    tag 'article:id' do |tag|
      if tag.locals.article['id']
        tag.locals.article['id']
      else
        Hammer.key_missing "id", {parent_key: "article"}
      end
    end

    tag 'article:name' do |tag|
      if tag.locals.article['name']
        tag.locals.article['name']
      else
        Hammer.key_missing "name", {parent_key: "article"}
      end
    end

    tag 'article:title' do |tag|
      if tag.locals.article['title']
        tag.locals.article['title']
      else
        Hammer.key_missing "title", {parent_key: "article"}
      end
    end

    tag 'article:path' do |tag|
      if tag.locals.article['url']
        tag.locals.article['url']
      else
        tag.render 'page:url', tag.attr
      end
    end

    tag 'article:content' do |tag|
      # tag.render 'page:content', tag.attr
      tag.locals.article[:content]
    end

    tag 'article:tags' do |tag|
      # tag.locals.article.label_list.join(',')
      if tag.locals.article['tags'].kind_of?(Array)
        tag.locals.article['tags'].join(',')
      elsif
        Hammer.error 'Article tags should be an array'
      end
    end

    tag 'article:published_at' do |tag|
      if tag.locals.article[:published_at]
        tag.locals.article[:published_at]
      else
        "#{(0..10).to_a.sample} days ago"
      end
    end

    tag 'article:author_first_name' do |tag|
      if tag.locals.article[:created_by][:first_name]
        tag.locals.article[:created_by][:first_name]
      else
        Hammer.key_missing "first_name", {parent_key: "article"}
      end
    end

    tag 'article:author_last_name' do |tag|
      if tag.locals.article[:created_by][:last_name]
        tag.locals.article[:created_by][:last_name]
      else
        Hammer.key_missing "last_name", {parent_key: "article"}
      end
    end

    tag 'article:author_full_name' do |tag|
      if tag.locals.article[:created_by]
        if tag.locals.article[:created_by][:first_name] || tag.locals.article[:created_by][:last_name]
          [tag.locals.article[:created_by][:first_name], tag.locals.article[:created_by][:last_name]].join(" ")
        else
          content = []
          content << (Hammer.key_missing "first_name or last_name", {parent_key: "article:created_by", comment: true, warning: true})
          content << [Faker::Name.first_name, Faker::Name.last_name].join(" ")
          content.join("")
        end
      else
        content = []
        content << (Hammer.key_missing "created_by", {parent_key: "article", comment: true})
        content << [Faker::Name.first_name, Faker::Name.last_name].join(" ")
        content.join("")
      end
    end

    tag 'articles' do |tag|

      tag.locals.blog ||= load_blog(tag)
      if tag.locals.blog['articles']
        tag.locals.articles = tag.locals.blog['articles']
        tag.expand
      else
        Hammer.key_missing "articles", {parent_key: "blog"}
      end
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
      if tag.locals.articles.count.nil? || tag.locals.articles.count == 0
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

        tag.locals.blog ||= load_blog(tag)

        if tag.locals.blog[:archive] && tag.locals.blog[:archive][:monthly] && tag.locals.blog[:archive][:monthly].count > 0
          data = tag.locals.blog[:archive][:monthly]
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

        tag.locals.errors = []
        if tag.globals.context.data['page']
          tag.locals.page = tag.globals.context.data['page']
        else
          tag.locals.errors << (Hammer.key_missing "page")
        end

        blogs = tag.globals.context.data['blogs'] || tag.globals.context.data['blog']

        if tag.globals.context.data['blog']
          tag.locals.errors << (Hammer.error "Depreciation Notice: <code>blog:</code> key to be renamed <code>blogs:</code> in future release", {comment: true, warning: true})
        end
        if blogs
          if blogs.kind_of?(Array)
            if blogs.select{|w| w['id'].to_s == (tag.locals.page['id'].to_s) }.first
              tag.locals.blog = blogs.select{|w| w['id'].to_s == (tag.locals.page['id'].to_s) }.first
            else
              tag.locals.errors << (Hammer.error "Could not find blog with id: #{tag.locals.page['id']} in mock_data.yml")
            end
          else
            tag.locals.errors << (Hammer.error "Depreciation Notice: in future release <code>blogs:</code> should be an Array in mock_data.yml", {comment: true, warning: true})
            tag.locals.blog = tag.globals.context.data['blog']
          end
        else
          tag.locals.errors << (Hammer.key_missing "blogs")
        end
      end

      def load_article(tag)
        # if tag.globals.context.data && tag.globals.context.data['blog'] && tag.globals.context.data['blog'].first['articles']
        #   tag.globals.context.data['blog'].first['articles'].sample
        # else
        #   content = <<-CONTENT
        #     <p>#{Faker::Lorem.paragraph(2)}</p>
        #     <p>#{Faker::Lorem.paragraph(5)}</p>
        #     <p>#{Faker::Lorem.paragraph(3)}</p>
        #   CONTENT
        #   article = {
        #     :name => Faker::Lorem.sentence(1),
        #     :title => Faker::Lorem.sentence(1),
        #     :created_by => { :first_name => Faker::Name.first_name, :last_name =>  Faker::Name.last_name },
        #     :content => content,
        #     :published_at => Random.rand(11).to_s+ " days ago"
        #   }
        #   tag.locals.article = article
        #   article
        # end
        tag.locals.blog['articles'].sample
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
        if tag.globals.context.data['blog'].kind_of?(Array)
          tag.globals.context.data['blog'].first['articles'].count
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

        if tag.attributes
          if tag.attributes['limit']
            limit = tag.attributes['limit'].to_i - 1
            items = target[0..limit]
          else
            items = target
          end
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
        # z = tag.globals.page.request_path
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
