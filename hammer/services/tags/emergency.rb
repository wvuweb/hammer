require 'chronic'

module Tags
  class Emergency < TagContainer

    tag 'emergency_status' do |tag|
      tag.locals.emergency_status ||= load_emergency_status(tag)
      tag.expand
    end

    tag 'emergency_status:status' do |tag|
      tag.locals.emergency_status['status']
    end

    tag 'emergency_status:updated_at' do |tag|
      format = (tag.attr['format'] || '%m/%d/%Y').strip
      parse_date(tag.locals.emergency_status['updated_at'], format)
    end

    tag 'emergency_site' do |tag|
      tag.locals.emergency_site ||= load_site(tag)
      tag.expand
    end

    tag 'emergency_site:published_at' do |tag|
      format = (tag.attr['format'] || '%m/%d/%Y').strip
      parse_date(tag.locals.emergency_site[:published_at], format)
    end

    tag 'events' do |tag|
      if tag.globals.context.data && tag.globals.context.data['events']
        tag.locals.events = tag.globals.context.data['events']
      end
      tag.expand
    end

    tag 'events:count' do |tag|
      count_items tag, tag.locals.events
    end

    tag 'event' do |tag|
      tag.locals.event ||= load_event(tag)
      tag.expand
    end

    tag 'event:id' do |tag|
      tag.locals.event['id']
    end

    tag 'event:name' do |tag|
      tag.locals.event['name']
    end

    tag 'event:title' do |tag|
      tag.locals.event['title']
    end

    tag 'event:author' do |tag|
      tag.locals.event['updated_by'].map {|n| n[1]}.join(' ')
    end

    tag 'event:updated_at' do |tag|
      format = (tag.attr['format'] || '%m/%d/%Y').strip
      parse_date(tag.locals.event['updated_at'], format)
    end

    tag 'event:content' do |tag|

      if tag.locals.event[:content]
        tag.locals.event[:content]
      else
        Hammer.error 'Set key <em>events:event:content</em> in mock_data file'
      end
    end

    tag 'events:each' do |tag|
      loop_over tag, tag.locals.events
    end

    class << self

      def parse_date(str,format)
        # We will try parsing the date string with Chronic first. If that doesn't work, we'll attempt to
        # parse the string with DateTime.
        Time.zone = "Eastern Time (US & Canada)"
        Chronic.time_class = Time.zone
        date = Chronic.parse(str) || DateTime.parse(str) rescue nil
        if format
          date.strftime(format)
        end
      end

      def count_items(tag, target)
        # filter_events(tag, target).total_count
        if tag.globals.context.data && tag.globals.context.data['events']
          tag.globals.context.data['events'].count
        else
          0
        end
      end

      def loop_over(tag, target)

        items = target

        output = []
        items.each_with_index do |item, index|
          event = item
          tag.locals.event = event
          output << tag.expand
        end

        output.flatten.join('')
      end

      def load_site(tag)
        if tag.globals.context.data && tag.globals.context.data['site']
          tag.locals.emergency_site = tag.globals.context.data['site']
        else
          site = {
            :published_at => Random.rand(11).to_s+ " days ago"
          }
          tag.locals.emergency_site = site
        end
      end

      def load_emergency_status(tag)
        # page = tag.globals.page
        #page.type == 'ArticlePage' ? decorated_page(page) : nil
        if tag.globals.context.data && tag.globals.context.data['emergency_status']
          tag.locals.emergency_status = tag.globals.context.data['emergency_status']
        else
          emergency_status = {
            :status => [true, false].sample,
            :updated_at => Random.rand(11).to_s+ " days ago"
          }
          tag.locals.emergency_status = emergency_status
        end
      end

      def load_event(tag)
        # page = tag.globals.page
        #page.type == 'ArticlePage' ? decorated_page(page) : nil
        if tag.globals.context.data && tag.globals.context.data['events']
          tag.globals.context.data['events'].first
        else
          content = <<-CONTENT
            <p>#{Faker::Lorem.paragraph(2)}</p>
            <p>#{Faker::Lorem.paragraph(5)}</p>
            <p>#{Faker::Lorem.paragraph(3)}</p>
          CONTENT
          event = {
            :title => Faker::Lorem.sentence(1),
            :created_by => { :first_name => Faker::Name.first_name, :last_name =>  Faker::Name.last_name },
            :content => content,
            :published_at => Random.rand(11).to_s+ " days ago"
          }
          tag.locals.event = event
          event
        end
      end

    end

  end
end
