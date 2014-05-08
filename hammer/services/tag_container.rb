# encoding: utf-8

class TagContainer
  
  def self.tag(name, &block)
    (@tags ||= []) << "tag:#{name}"
    define_singleton_method "tag:#{name}", &block
  end
    
  def self.tags
    @tags
  end
  
end