module Radius
  class TagBinding
    
    # We override the built-in TagBinding#attributes method so that we can parse/process the
    # attribute values. This allows us to use page/URL parameters for attribute values.
    #
    # Example usage:
    #  <r:sometag foo="{$bar}" />
    #
    #  This would substitute the value of the 'bar' variable from globals.vars, if it exists.
    def attributes
      @attributes.inject({}) do |memo, (k, v)|
        memo[k] = parse_value(v)
        memo
      end.with_indifferent_access
    end
    alias :attr :attributes
    
    private
    
    def parse_value(v)
      str = v.to_s.strip
      if str =~ /^{\s*\$(\w+)\s*}$/
        (globals.vars || {})[$1]
      elsif str =~ /^{\s*(\w+(?::\w+)*)\s*}$/
        render($1)
      else
        v
      end
    end
  end
end