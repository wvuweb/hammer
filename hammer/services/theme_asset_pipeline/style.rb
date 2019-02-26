module ThemeAssetPipeline
  class Style < Parser
    def compile(file)
      cfilename = compiled_filename(file)
      if File.exists?(cfilename)
        css = File.read(cfilename)
      else
        # Compile the given file
        begin
          css = Sass::Engine.new(File.read(file), :syntax => syntax(file), :style => style, :load_paths => load_paths).render
        rescue Sass::SyntaxError => e
          raise Slate::Errors::ThemeCSS.new(e.message)
        end

        # Write the compiled result to a new file
        File.write(cfilename, css)

        # Cleanup old compiled files
        Dir.glob("#{file}.[0-9]*").each {|f| File.delete(f) unless f == cfilename }
      end

      css
    end

    def content
      all_content = ""
      @file_paths.each { |file| all_content.concat(compile(file)) }
      all_content
      # process_image_urls all_content
    end

    def content_type
      'text/css'
    end

    private

    # This method will replace all theme image references with a properly
    # formatted and versioned URL.
    #
    # Example:
    #
    #   background: url(../images/flying-wv-w-signature.png) left 1px no-repeat;
    #
    # will be replaced with
    #
    #   background: url(/images/1234567/flying-wv-w-signature.png) left 1px no-repeat;
    #
    # def process_image_urls(content)
    #   base_url = @options[:base_url] || ''
    #   content.gsub(/url\(\s*["']?(?:\.\.)?\/(images|public)\/(.*?)["']?\)/, "url(\"#{base_url}/\\1/#{@theme.url_fingerprint}/\\2\")")
    # end

    def syntax(file)
      ext = File.extname(file).gsub(/^\./, '')
      if %w(sass scss).include?(ext)
        ext.to_sym
      elsif ext == 'css'
        :scss
      end
    end

    def style
      compress = theme.config['css']['compress']
      compress ? :compressed : :expanded
    end

    def load_paths
      # Pathname.new([@theme,'stylesheets'].join('/'))
      [File.join(@theme, 'stylesheets')]
    end
  end
end
