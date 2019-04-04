# encoding: utf-8
require "../hammer/services/tag_container.rb"
require "../hammer/services/tag_binding.rb"

Dir["../hammer/services/tags/*.rb"].each {|file|
  require file
}

class ThemeContext < ::Radius::Context

  def initialize(data = {})
    super
    @context = data

    unless @context == {}

      globals.context = @context
      globals.vars = @context.request.query || {}

      load_tags_from Tags::ThemeAsset
      load_tags_from Tags::Basic
      load_tags_from Tags::Menus
      load_tags_from Tags::Page
      load_tags_from Tags::Content
      load_tags_from Tags::Blog
      load_tags_from Tags::Asset

      if @context.config["theme_type"] == "Emergency"
        load_tags_from Tags::Emergency
      end
    end
  end

  def self.tag(name, &block)
    (@tags ||= []) << "tag:#{name}"
    define_singleton_method "tag:#{name}", &block
  end

  def tag_missing(name, attributes, &block)
    style = "background-color: #eee; border-radius: 3px; font-family: monospace; padding: 0 3px;"
    Hammer.error "OH NOES! Tag or tag method <code style='#{style}'>#{name}</code> does not yet exist in hammer.  Be a good samaritan and <a href=\"https://github.com/wvuweb/hammer/issues\">file a Github issue!</a>"
  end

  private
  def load_tags_from(object)
    method_regex = /^tag:/
    tag_methods = object.methods.grep(method_regex).sort

    tag_methods.each do |mname|
      tag_method = object.method(mname)
      define_tag mname[4..-1] do |tag_binding|
        if tag_method.arity == 0
          tag_method.call
        else
          begin
            tag_method.call tag_binding
          rescue TypeError => e
            Hammer.error "Something is wrong with radius #{mname} <strong>Error Message:</strong> #{e} #{e.backtrace.first}"
          end
        end
      end
    end
  end

end
