# encoding: utf-8

require_relative "tag_binding.rb"


require_relative 'tags/theme_asset.rb'
require_relative 'tags/basic.rb'
require_relative 'tags/menus.rb'
require_relative 'tags/page.rb'
require_relative 'tags/content.rb'
require_relative 'tags/blog.rb'
require_relative 'tags/asset.rb'
require_relative 'tags/emergency.rb'

class ThemeContext < ::Radius::Context

  attr_accessor :errors

  def initialize(data = {})
    super
    @context = data
    @errors = []

    unless @context == {}

      globals.context = @context
      globals.vars = @context.request.query || {}

      load_tags_from ::Tags::ThemeAsset
      load_tags_from ::Tags::Basic
      load_tags_from ::Tags::Menus
      load_tags_from ::Tags::Page
      load_tags_from ::Tags::Content
      load_tags_from ::Tags::Blog
      load_tags_from ::Tags::Asset

      if @context.config["theme_type"] == "Emergency"
        load_tags_from ::Tags::Emergency
      end
    end
  end

  def self.tag(name, &block)
    (@tags ||= []) << "tag:#{name}"
    define_singleton_method "tag:#{name}", &block
  end

  def tag_missing(name, attributes, &block)
    error = Hammer.error "Tag or tag method <code>#{name}</code> does not exist.  If this is a real tag, be a good samaritan and <a href=\"https://github.com/wvuweb/hammer/issues\">file a Github issue!</a>"
    @errors << error
    error
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
            @errors << (Hammer.error "Something is wrong with tag <code>#{mname}</code> <strong>Trace:</strong> #{e} #{e.backtrace.first}")
          rescue NoMethodError => e
            @errors << (Hammer.error "Tag <code>#{mname}</code> did not load, it is likely missing data in mock_data.yml <strong>Trace:</strong> #{e}")
          end
        end
      end
    end
  end

end
