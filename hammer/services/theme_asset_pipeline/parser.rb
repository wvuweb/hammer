module ThemeAssetPipeline
  class Parser
    attr_reader :theme, :last_modified, :etag

    def initialize(theme, request_path, options = {})
      @request_path = request_path
      @theme = theme
      @options = options

      parse_asset_files
    end

    def is_map_resource?
      File.extname(@request_path).to_s.downcase == '.map'
    end

    def file_path
      path = @file_paths.first
      raise Slate::Errors::FileNotFound unless path.present? and File.exists?(path)
      path
    end

    protected

    def parse_asset_files
      files = @request_path.split('&')
      @file_paths = []
      # @etag = @last_modified = @theme.updated_at
      files.each do |file|
        paths = load_paths.map { |path| File.join(path, file) }

        if file_path = find_file(paths)
          @file_paths << file_path
        end
      end
      binding.pry
    end

    def find_file(paths)
      paths = [paths] unless Array === paths
      paths.map do |path|
        return path if File.exists?(path)
        Dir.glob(path + '*')
      end.flatten.first
    end

    def compiled_filename(file)
      #file + ".#{@theme.url_fingerprint}"
      file
    end
  end
end
