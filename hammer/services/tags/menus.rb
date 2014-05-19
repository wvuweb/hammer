

module Tags  
  class Menus < TagContainer
    
    tag 'site_menu' do |tag|
      if tag.globals.context.data && tag.globals.context.data['site_menu']
        tag.globals.context.data['site_menu']
      else
        <<-MENU
        <ul>
          <li class="active"><a href="#">Page 1</a></li>
          <li><a href="#">Page 2</a></li>
          <li><a href="#">Page 3</a></li>
          <li><a href="#">Page 4</a></li>
          <li><a href="#">Page 5</a></li>
        </ul>
        MENU
      end
    end
    
    tag 'sub_menu' do |tag|
      if tag.globals.context.data && tag.globals.context.data['sub_menu']
        tag.globals.context.data['sub_menu']
      else
        <<-MENU
        <ul>
          <li class="active"><a href="#">Sub Page 1</a></li>
          <li><a href="#">Sub Page 2</a></li>
          <li><a href="#">Sub Page 3</a></li>
          <li><a href="#">Sub Page 4</a></li>
          <li><a href="#">Sub Page 5</a></li>
        </ul>
        MENU
      end
    end
    
    tag 'ancestor_menu' do |tag|
      if tag.globals.context.data && tag.globals.context.data['ancestor_menu']
        tag.globals.context.data['ancestor_menu']
      else
        <<-MENU
        <ul>
          <li class="active"><a href="#">Sub Page 1</a></li>
          <li><a href="#">Sub Page 2</a></li>
          <li><a href="#">Sub Page 3</a></li>
          <li><a href="#">Sub Page 4</a></li>
          <li><a href="#">Sub Page 5</a></li>
        </ul>
        MENU
      end
    end

  end
end