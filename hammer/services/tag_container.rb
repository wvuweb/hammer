# encoding: utf-8

require 'action_view'
require 'active_support/core_ext/string/output_safety'

class TagContainer

  def self.tag(name, &block)
    (@tags ||= []) << "tag:#{name}"
    define_singleton_method "tag:#{name}", &block
  end

  def self.tags
    @tags
  end

end
