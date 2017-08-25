module ThemeAssetPipeline
  class Javascript < Parser
    def compile(file_path)
      cfilename = compiled_filename(file_path)

      if File.exists?(cfilename)
        content = File.read(cfilename)
      else
        theme_config = theme.config
        compress = theme_config['js']['compress']
        mangle = theme_config['js']['mangle']

        ext = File.extname(file_path).gsub(/^\./, '')
        content = File.read(file_path)

        # Compile CoffeeScript, if needed.
        begin
          content = CoffeeScript.compile(content) if ext == 'coffee'
        rescue Exception => e
          raise Slate::Errors::ThemeJavascript.new(e.message)
        end

        # Compress and mangle, if needed.
        content = Uglifier.compile(content, :squeeze => compress, :mangle => mangle) if compress || mangle

        # Write the compiled result to a new file
        File.write(cfilename, content)

        # Cleanup old compiled files
        Dir.glob("#{file_path}.[0-9]*").each {|f| File.delete(f) unless f == cfilename }
      end

      content
    end

    def content
      all_content = []
      @file_paths.each { |file| all_content << compile(file) }
      all_content.join("\n")
    end

    def content_type
      'text/javascript'
    end

    private

    def load_paths
      [theme.javascript_dir]
    end
  end
end
