module ThemeAssetPipeline
  class Resource
    attr_reader :theme, :last_modified, :etag, :file_path

    def initialize(theme, request_path)
      @request_path = request_path
      @theme = theme

      @file_path = @theme.resource_path(@request_path)

      raise Slate::Errors::FileNotFound unless File.exists?(@file_path)
      @last_modified = File.mtime(@file_path).utc
    end

    def etag
      @theme.updated_at
    end
  end
end
