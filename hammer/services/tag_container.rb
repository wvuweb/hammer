# encoding: utf-8

require 'action_view'
require 'active_support/core_ext/string/output_safety'

require '../hammer/services/theme_asset_pipeline/parser.rb'
require '../hammer/services/theme_asset_pipeline/image.rb'
require '../hammer/services/theme_asset_pipeline/javascript.rb'
require '../hammer/services/theme_asset_pipeline/resource.rb'
require '../hammer/services/theme_asset_pipeline/style.rb'

class TagContainer

  def self.tag(name, &block)
    (@tags ||= []) << "tag:#{name}"
    define_singleton_method "tag:#{name}", &block
  end

  def self.tags
    @tags
  end

end
