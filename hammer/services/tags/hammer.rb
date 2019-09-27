require_relative "../tag_container.rb"

module Tags
  class HammerTag < TagContainer

    tag 'hammer_breadcrumbs' do |tag|
      current = []
      output = []
      output << "<ul class='wvu-hammer-breadcrumbs__crumbs''>"
      tag.globals.context.request.path.split('/').each do |part|
        if part == ""
          output << "<li><a class='wvu-hammer-link' href='/'>Themes</a></li>"
        else
          current << part
        end
      end
      current.each_with_index do |part,index|
        if current.size == (index + 1)
          output << "<li>"+part+"</li>"
        else
          output << "<li><a class='wvu-hammer-link' href='/"+current[(0..index)].join('/')+"'>"+part+"</a></li>"
        end
      end
      output << "</ul>"
      output.join("")
    end

    tag 'hammer_nav' do |tag|
      if !tag.globals.context.data['hammer_nav'] || !tag.globals.context.data['hammer_nav']['disabled']
        tag.expand
      end
    end

    tag 'hammer_version' do |tag|

      if tag.globals.context.version.class == Array
        version = tag.globals.context.version[0] + " - <span data-commit-hash="+tag.globals.context.version[2]+"> " + tag.globals.context.version[1] + " ahead</span>"
      else
        version = tag.globals.context.version
      end

      if tag.globals.context.version_behind
        message = version + "behind latest"
        klass = "wvu-hammer-link__warning"
      else
        message = version
        klass = ""
      end
      output = "Version:&nbsp;<a class='wvu-hammer-link"+klass+"' href='https://github.com/wvuweb/hammer/blob/master/CHANGELOG.md' target='_new' title='View Change Log'>"+message+"</a>"
      output
    end

  end
end
