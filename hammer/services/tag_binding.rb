require 'dentaku'

module Radius
  class TagBinding

    CALCULATOR = Dentaku::Calculator.new

    # Evaluates the current tag and returns the rendered contents.
    def expand(newcontext=nil,oldcontext=nil)
      unless oldcontext.nil? && newcontext.nil?
        globals.context.data['page'] = newcontext
      end
      double? ? block.call : ''
      if double?
        output = block.call
        unless oldcontext.nil? && newcontext.nil?
          globals.context.data['page'] = oldcontext
        end
        output
      else
        ''
      end
    end

    # CALCULATOR.add_functions(Dentaku::CustomFunctions::FUNCTIONS)

    # We override the built-in TagBinding#attributes method so that we can parse/process the
    # attribute values. This allows us to use page/URL parameters for attribute values.
    #
    # Example usage:
    #  <r:sometag foo="{$bar}" />
    #
    #  This would substitute the value of the 'bar' variable from globals.vars, if it exists.
    def attributes
      @attributes.inject({}) do |memo, (k, v)|
        begin
          memo[k] = parse_value(v)
        rescue Exception => e
          memo[k] = Hammer.error "<strong>Attribute Error</strong> #{name} #{e}"
          #raise AttributeParseError.new(name, k, v, e.backtrace)
        end

        memo
      end.with_indifferent_access
    end
    alias :attr :attributes

    # This is a utility method that makes it easy to retrieve a tag attribute value
    # from an array of possible key names. For example, if you could refer to the
    # same tag attribute via either "foo1", "f1", or "foo_1", you could call
    # fetch_attr(['foo1', 'f1', 'foo_1']) and it would return value for the first
    # matching tag attribute, if one exists.
    def fetch_attr(name)
      key = name.is_a?(Array) ? (self.attr.keys & name).first : name
      self.attr[key]
    end

    def cache_key
      Digest::MD5.hexdigest("#{self.name}#{self.attributes.sort.flatten.join}")
    end

    def dictionary
      dict = {}

      # Include theme custom data
      if theme = globals.theme
        dict.merge!(theme.config['data']) if theme.config['data'].present?
      end

      # Include custom site data attributes, if they exist.
      # if site = locals.site
      #   dict.merge!(site.custom_data) if site.custom_data.present?
      # end
      #
      # if page = locals.page
      #   # Include custom page data attributes, if they exist.
      #   dict.merge!(page.custom_data) if page.custom_data.present?
      #
      #   # Include any variables from the URL query string, if they exist.
      #   dict.merge!(page.params) if page.params.present?
      #
      #   # Include access to page attributes that are Radius accessible.
      #   page.radius_attributes.each do |attr|
      #     dict[attr.to_s] = page.send(attr.to_sym)
      #   end
      # end

      if globals.context.data['site']['data']
        dict.merge!(globals.context.data['site']['data'])
      end

      if globals.context.data['page']['data']
        dict.merge!(globals.context.data['page']['data'])
      end

      # Include global template variables.
      dict.merge!(globals.vars) if globals.vars

      dict
    end

    private

    def math_dictionary
      dictionary.inject({}) do |memo, (key, value)|
        memo[key] = if value.to_s.strip =~ /^\d+(?:\.\d+)?$/
          value.to_f
        else
          value
        end

        memo
      end
    end

    def parse_value(v)
      str = v.to_s.strip
      if str =~ /^{\s*\$(\w+)\s*}$/
        # Parse a variable reference (attr1="{$var_name}")
        dictionary[$1].to_s
      elsif str =~ /^{{\s*(.*)\s*}}$/
        # Evaluate mathematical expressions (attr1="{{ 123 + var_name / 2 }}")
        CALCULATOR.clear
        CALCULATOR.evaluate!($1, math_dictionary)
      elsif str =~ /^{\s*(\w+(?::\w+)*)\s*}$/
        # Parse a tag reference (attr1="{page:name}")
        render($1)
      else
        v
      end
    end
  end
end
