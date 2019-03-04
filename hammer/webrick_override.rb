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
          host: req.host,
          port: req.port,
          software: @config[:ServerSoftware]
        }

        res.body = format_directory(html)

        # res.body = <<-_end_of_html_
        #   <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
        #   <HTML>
        #   <HEAD>
        #   <TITLE>#{title}</TITLE>
        #   <style type="text/css">
        #   <!--
        #   .name, .mtime { text-align: left; }
        #   .size { text-align: right; }
        #   td { text-overflow: ellipsis; white-space: nowrap; overflow: hidden; }
        #   table { border-collapse: collapse; }
        #   tr th { border-bottom: 2px groove; }
        #   //-->
        #   </style>
        #   </HEAD>
        #   <BODY>
        #   <H1>HAMMER: #{title}</H1>
        #
        #     _end_of_html_
        #
        #     res.body << "<TABLE width=\"100%\"><THEAD><TR>\n"
        #     res.body << "<TH class=\"name\"><A HREF=\"?N=#{d1}#{query}\">Name</A></TH>"
        #     res.body << "<TH class=\"mtime\"><A HREF=\"?M=#{d1}#{query}\">Last modified</A></TH>"
        #     res.body << "<TH class=\"size\"><A HREF=\"?S=#{d1}#{query}\">Size</A></TH>\n"
        #     res.body << "</TR></THEAD>\n"
        #     res.body << "<TBODY>\n"
        #
        #     query.sub!(/\A&/, '?')
        #     list.unshift [ "..", File::mtime(local_path+"/.."), -1 ]
        #     list.each{ |name, time, size|
        #       if name == ".."
        #         dname = "Parent Directory"
        #       elsif namewidth and name.size > namewidth
        #         dname = name[0...(namewidth - 2)] << '..'
        #       else
        #         dname = name
        #       end
        #       s =  "<TR><TD class=\"name\"><A HREF=\"#{HTTPUtils::escape(name)}#{query if name.end_with?('/')}\">#{HTMLUtils::escape(dname)}</A></TD>"
        #       s << "<TD class=\"mtime\">" << (time ? time.strftime("%Y/%m/%d %H:%M") : "") << "</TD>"
        #       s << "<TD class=\"size\">" << (size >= 0 ? size.to_s : "-") << "</TD></TR>\n"
        #       res.body << s
        #     }
        #     res.body << "</TBODY></TABLE>"
        #     res.body << "<HR>"
        #
        #     res.body << <<-_end_of_html_
        #   <ADDRESS>
        #   #{HTMLUtils::escape(@config[:ServerSoftware])}<BR>
        #   at #{req.host}:#{req.port}
        #   </ADDRESS>
        #   </BODY>
        #   </HTML>
        #     _end_of_html_
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
