# encoding: utf-8


require "../hammer/services/tag_container.rb"
#require '../hammer/services/tags/basic.rb'
Dir["../hammer/services/tags/*.rb"].each {|file|
  require file 
}

class ThemeContext < ::Radius::Context
  
  def initialize(data = {})
    super
    @context = data
    
    globals.context = @context
    
    load_tags_from Tags::ThemeAsset
    load_tags_from Tags::Basic
    load_tags_from Tags::Menus
    load_tags_from Tags::Page
    load_tags_from Tags::Content
    load_tags_from Tags::Blog
    load_tags_from Tags::Asset
  end
  
  def self.tag(name, &block)
    (@tags ||= []) << "tag:#{name}"
    define_singleton_method "tag:#{name}", &block
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