require 'active_support/all'
require 'time'
require 'chronic'

module Tags  
  class Basic < TagContainer
    tag 'comment' do |tag|
      # Do nothing.
      nil
    end
    
    # Site tags
    tag 'site_name' do |tag|
      # tag.globals.site.name
      if tag.globals.context.data
        if tag.globals.context.data['site'] && tag.globals.context.data['site']['name']
          tag.globals.context.data['site']['name'] 
        elsif tag.globals.context.data['site_name']
          tag.globals.context.data['site_name']
        else
          Hammer.error "<strong>Depreciated</strong> tag please use <r:site:name />."
        end
      else
        "Site Name"
      end
    end
    
    tag 'site' do |tag|
      tag.locals.site ||= tag.globals.site
      tag.expand
    end
    
    [:id, :name, :domain].each do |attr|
      tag "site:#{attr.to_s}" do |tag|
        # tag.locals.page.send(attr)
        #{"}fix page:#{attr.to_s} tag"
        if tag.globals.context.data && tag.globals.context.data['site'] && tag.globals.context.data['site'][attr.to_s]
          tag.globals.context.data['site'][attr.to_s]
        else
          Hammer.error "Add key <em> page:#{attr}</em>"
        end
      end
    end
    
    # Returns the number of sites with the given status. Status can be one of: live, development,
    # archived, active, all. Live and development sites are considered 'active'. 
    tag 'site_count' do |tag|
      status = tag.attr['status'] ||= 'all'
      
      count = case status
      when *%w(live development archived active)
        # ::Site.send(status.to_sym).count
        Random.rand(0..999)
      else
        Random.rand(0..999)
      end
      
      count.to_s
    end
    
    tag 'current_url' do |tag|
      type = tag.attr['type'] || 'absolute'
      case type.downcase
        when 'absolute' 
          then
            #tag.globals.page.request_path
            tag.context.globals.context.request.path
        when 'full' 
          then
            #tag.globals.page.request_url
            tag.context.globals.context.request.request_uri.to_s
      end
      # Hammer.error "current_url tag is not implemented yet"
    end
    
    # Renders an unordered list (<ul>) of HTML links to the pages leading to the current page. If the 'text_only'
    # attribute is 'true', then instead of a list of HTML links, a plain text list will be rendered with the
    # value of the 'separator' attribute used to separate each item. The default separator is ' | '.
    #
    # Examples:
    #   <r:breadcrumbs />
    #
    #   <r:breadcrumbs ul_id="breadcrumbs-top" ul_class="breadcrumb" active_class="current" no_self="true" />
    #
    #   <r:breadcrumbs text_only="true" no_self="true" separator=" &rarr; " />
    tag 'breadcrumbs' do |tag|
      allowed_options = %w(ul_id ul_class active_class no_self no_root text_only separator reverse attr)
      # page = tag.locals.page
      options = tag.attr.select{ |k,v| allowed_options.include?(k) }
      # options['mode'] = tag.globals.mode
      # 
      # %w(no_self no_root text_only reverse).each do |i|
      #   binding.pry
      #   options[i] = options[i].to_s.to_boolean
      # end
      if tag.globals.context.data && tag.globals.context.data[:breadcrumbs]
        tag.globals.context.data[:breadcrumbs]
      else
        options['text_only'] ? self.breadcrumb_text(options) : self.breadcrumb_list(options)
      end
      
      #Hammer.error "breadcrumb tag is not implemented yet"
      
    end
    
    # Retrieve the value of a variable.
    #
    # Example using a default value:
    #   <r:var name="foo" default="bar" />
    #
    # Example retrieving variable with no default:
    #   <r:var name="foo" />
    tag 'var' do |tag|
      # name = tag.attr['name']
      # default = tag.attr['default']
      # 
      # value = tag.globals.vars[name]
      # value.blank? && default.present? ? default : value
      Hammer.error "var tag is not implemented yet"
    end
    
    # Set the value of a variable.
    #
    # Examples:
    #
    #   Set the 'foo' variable to 'bar'. 
    #
    #   <r:set_var name="foo" value="bar" />
    #
    #   The following will set the 'baz' variable to the current value of the 'foo' variable.
    #   If the 'foo' variable is not currently set, the default value 'raz' will be used.
    #
    #   <r:set_var name="baz" value="{foo}" default="baz" />
    tag 'set_var' do |tag|
      name = tag.attr['name']
      value = tag.attr['value']
      default = tag.attr['default']
      
      value = default if value.blank? && default.present?
      
      tag.globals.vars[name] = value
      nil
      # Hammer.error "set_var tag is not implemented yet"
    end
    
    # Replace content contained within the tag that matches the 'match' attribute with
    # the value contained in the 'with' attribute.
    #
    # Example: <r:replace match="\d" with="X">123</r:replace>
    #
    # The above should render 'XXX' as the output.
    tag 'replace' do |tag|
      match = tag.attr['match']
      value = tag.attr['with']
      scope = tag.attr['scope'] || 'all'
      
      # Determine which string replacement method to use.
      rmethod = scope.downcase == 'all' ? :gsub : :sub

      content = tag.expand
      content.send rmethod, /#{match}/, value
    end
    
    # Parse a date string and return a new string with the given format. The string to parse
    # can be given in the 'value' attribute, or specified in the tag content.
    #
    # <r:date_format format="%m/%d/%Y %H:%M:%s" value="December 12, 2012 at 10:56 AM" />
    # 
    # <r:date_format format="%m/%d/%Y %H:%M:%s">
    #    December 12, 2012 at 10:56 AM
    # </r:date_format>
    tag 'date_format' do |tag|
      format = (tag.attr['format'] || '%m/%d/%Y').strip
      date_str = tag.attr['value']
      error_msg = tag.attr['error_msg'] || "Error: Could not parse date string '#{date_str}'."
      
      date_str = tag.expand.strip if tag.double? && date_str.blank?
      
      format_method = case format
      when /rfc822|iso8601|httpdate/
        [format.to_sym]
      else
        [:strftime, format]
      end
      
      # We will try parsing the date string with Chronic first. If that doesn't work, we'll attempt to
      # parse the string with DateTime.
      Chronic.time_class = Time
      date = Chronic.parse(date_str) || DateTime.parse(date_str) rescue nil
      date.present? ? date.send(*format_method) : error_msg
      
      # Hammer.error "date_format tag is not implemented yet"
    end
    
    tag 'select_html' do |tag|
      css_selector = tag.attr['css_selector']
      limit = tag.attr['limit']
      content = tag.expand
      output = ''
      
      begin
        html = Nokogiri::HTML(content)
        results = html.css(css_selector.to_s)
        output = (limit.present? ? results.first(limit.to_i).collect(&:to_s) : results).join('')
      rescue
        output = "ERROR: Could not parse content."
      end
      
      output
      # tag.expand
      # Hammer.error "select_html tag is not implemented yet"
    end
    
    tag 'escape_xml' do |tag|
      # content = tag.expand
      # CGI::escapeHTML content
      Hammer.error "escape_xml tag is not implemented yet"
    end
    
    def self.breadcrumb_list(options)
      <<-BREADCRUMB_LIST
      <ul class="#{options['ul_class']}">
        <li><a href="#home">Home</a></li>
        <li class="active"><a href="#page">Page</a></li>
      </ul>
      BREADCRUMB_LIST
    end
    
    def self.breadcrumb_text(options)
      <<-BREADCRUMB_LIST
      <a href="#home">Home</a>| <a href="#page">Page</a>
      BREADCRUMB_LIST
    end
  end
end
