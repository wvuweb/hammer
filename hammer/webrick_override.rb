require 'erb'
require 'tilt'
require 'tilt/erb'

module WEBrick
  module HTTPServlet
    class FileHandler < AbstractServlet

      def set_dir_list(req, res)
        redirect_to_directory_uri(req, res)
        unless @options[:FancyIndexing]
          raise HTTPStatus::Forbidden, "no access permission to `#{req.path}'"
        end
        local_path = res.filename
        list = Dir::entries(local_path).collect{|name|
          next if name == "." || name == ".."
          next if nondisclosure_name?(name)
          next if windows_ambiguous_name?(name)
          st = (File::stat(File.join(local_path, name)) rescue nil)
          if st.nil?
            [ name, nil, -1 ]
          elsif st.directory?
            [ name + "/", st.mtime, -1 ]
          else
            [ name, st.mtime, st.size ]
          end
        }
        list.compact!

        query = req.query
        d0 = nil
        idx = nil
        %w[N M S].each_with_index do |q, i|
          if d = query.delete(q)
            idx ||= i
            d0 ||= d
          end
        end
        d0 ||= "A"
        idx ||= 0
        d1 = (d0 == "A") ? "D" : "A"

        if d0 == "A"
          list.sort!{|a,b| a[idx] <=> b[idx] }
        else
          list.sort!{|a,b| b[idx] <=> a[idx] }
        end

        namewidth = query["NameWidth"]
        if namewidth == "*"
          namewidth = nil
        elsif !namewidth or (namewidth = namewidth.to_i) < 2
          namewidth = 25
        end
        query = query.inject('') {|s, (k, v)| s << '&' << HTMLUtils::escape("#{k}=#{v}")}

        type = "text/html"
        case enc = Encoding.find('filesystem')
        when Encoding::US_ASCII, Encoding::ASCII_8BIT
        else
          type << "; charset=\"#{enc.name}\""
        end
        res['content-type'] = type

        title = "Index of #{HTMLUtils::escape(req.path)}"

        html = {
          local_path: local_path,
          d0: d0,
          d1: d1,
          idx: idx,
          query: query,
          namewidth: namewidth,
          title: title,
          list: list,
          path: req.path,
          host: req.host,
          port: req.port,
          software: @config[:ServerSoftware]
        }

        res.body = format_directory(html)
      end


      def format_directory(html)
        template = Tilt::ERBTemplate.new(File.expand_path File.dirname(__FILE__)+'/views/directory.erb')
        layout = Tilt::ERBTemplate.new(File.expand_path File.dirname(__FILE__)+'/views/layout/default.erb')
        context = Object.new
        layout.render(context, html: html) { template.render(context, html: html) }
      end
    end
  end
end
