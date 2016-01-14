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
    end
  end

  def self.tag(name, &block)
    (@tags ||= []) << "tag:#{name}"
    define_singleton_method "tag:#{name}", &block
  end

  def tag_missing(name, attributes, &block)
    Hammer.error "OH NOES! <em>&lt;r:#{name} /&gt;</em> does not yet exist in hammer.  Be a good samaritan and <a href=\"https://github.com/wvuweb/hammer/issues\">file a Github issue!</a>"
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
          tag_method.call tag_binding
        end
      end
    end
  end

end
