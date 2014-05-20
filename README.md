# Hammer

Hammer is a theme development tool for the [CleanSlate](http://cleanslate.wvu.edu/ "CleanSlate") CMS template rendering engine.  Hammer was created to help you iterate quickly on themes and template markup.  Hammer is **NOT** for content creation.  If you need to do content creation you may want the developer vagrant box.

Hammer is similar to [Mock Builder v2](https://github.com/wvuweb/mock_builder "Mock Builder v2") for [Slate](http://slatecms.wvu.edu/ "Slate"), but has many differences due to the many differences in [CleanSlate](http://cleanslate.wvu.edu/ "CleanSlate").  If you are familar with [Mock Builder v2](https://github.com/wvuweb/mock_builder "Mock Builder v2")  you should be able to quickly get up and running with Hammer.

###Dependencies

* Ruby 1.9.3-p484


###Mac OSX Installation

If you already have RVM installed due to a previous installation of [Mock Builder v2](https://github.com/wvuweb/mock_builder "Mock Builder"), skip to step 2.

1. Install RVM: [Ruby Version Manager](http://rvm.io/ "Ruby Version Manager")

    `\curl -sSL https://get.rvm.io | bash -s stable`
    
    then run
    
    `rvm requirements`

2. Checkout repo into your ~/Sites/ directory:

    `git clone git@github.com:wvuweb/hammer.git hammer`

3. Change directory to hammer install director

    `cd ~/Sites/hammer/`

4. If RVM prompts you for a missing ruby install run the following: 

    `rvm install 1.9.3-p484`

5. Then run 

    `bundle install`

5. Create a alias in your profile (.bash_profile or .profile)

    see bash configuration below:

#### bash config

copy and paste the following lines into your .bash_profile or .profile

```
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"

function hammer {
    if [ $# -eq 0 ]
        then
            echo -e "${COL_RED}Dropping the hammer on cleanslate_themes!!!${COL_RESET}";
        else
            echo -e "${COL_RED}Dropping the hammer on ${1}!!!${COL_RESET}";
    fi
    rvm use ruby-1.9.3-p484@hammer && cd ~/Sites/hammer/hammer/ && ruby hammer_server.rb ~/Sites/cleanslate_themes/$@;
}
```    

## Mock Data Example

If you are familar with [Mock Builder v2](https://github.com/wvuweb/mock_builder "Mock Builder v2") this mock_data.yml file will look familar if not identical to your previous usage.  

There are some fundemental differences however.

***livereload*** key is an Advanced topic covered in further detail the [Wiki](http://github.com/wvuweb/hammer/wiki "Link this to the wiki").  With this key you can enable javascript task runners such as grunt and gulp, to reload the page as you develop and save files.

***shared_themes*** key refers to the *partial* radius tag:

`<r:partial name="layouts/masthead--v1" theme="Code" />`

In this use case layouts/masthead--v1 partial exists in the Theme "Code"  The theme name must match how the theme is checked out from git on you local disk.  (ie.  ~/Sites/cleanslate_themes/code)

***editable_region*** key refers to the *editable_region* radius tag:

`<r:editable_region name="division-summary__header">`

In this use case the name of the editable region must exist under a editable_region parent key.  Unlike mock_builder hammer uses these parent keys to enable more flexibility in keys names for future radius tags that may later exist.

***site_name*** key refers to the site name of the theme. (ie. Diversity, ITS, English)

***page*** key refers to the current page being viewed in hammer.  The keys under *page* mimic the basic radius tag accessible attributes of a cleanslate page:

`id:, name:, slug:, meta_description:, title:, alternate_name:, depth:`

***if_page_depth_eq*** & ***if_page_depth_gt*** keys refer to their counterpart tags:

`<r:if_page_depth_gt page_depth="1">`
and
`<r:if_page_depth_eq page_depth="1">`
often times used to generate different menus based on the user navigating child and parent pages within a site.  These keys will allow you to manipulate Hammers rendering of the current template view as if the user was ascending or descending pages.

Hammer mock_data.yml can also use Ruby code (see ancestor menu example below) to [manipulate strings](http://www.tutorialspoint.com/ruby/ruby_strings.htm "Ruby Strings") or create menus as well as Faker objects: <https://github.com/stympy/faker> to auto generate words, paragraphs and sentences.

**Example:** Mock data file for cleanslate/hammer

```
livereload: true

shared_themes:
  layouts__masthead--v1: "code"
  layouts__footer__contact--v1: "code"
  layouts__footer__credits--v1: "code"
  layouts__footer__icons--v1: "code"
  layouts__browser-update-org--v1: "code"

editable_region:
  department-summary__header--how-do-i: "Spread the Word to End the Word."
  department-summary__main--how-do-i: 1
  department-summary__header--oas: "Some other random headline..."
  department-summary__main--oas: 5
  news: |
    <ul>
      <li><a href="#"><%= Faker::Business.credit_card_number %></a></li>
      <li><a href="#">Some Article link</a></li>
      <li><a href="#">Another Article link</a></li>
      <li><a href="#">An Amazing story</a></li>
    </ul>
  contact: |
    <p>1085 Van Voorhis Road Suite 250 | P.O. Box 6202<br>Morgantown,
    <span class="caps">WV 26506</span>-6202<br>Phone: 304.293.5600 | Fax: 304.293.8279<br>Email:
    <a href="mailto:diversity@mail.wvu.edu">diversity@mail.wvu.edu</a></p>
    
site_name: "Test Site"

page:
  id: 2
  name: "Test Page 2"
  slug: "test_page_2"
  meta_description: "Hello World"
  title: "This is the best Test page ever!"
  alternate_name: "Some other name"
  depth: 1

if_page_depth_eq: 1
if_page_depth_gt: 1

site_menu: |
  <ul>
    <li class="active"><a href="#">Hello</a></li>
    <li><a href="#">World</a></li>
    <li><a href="#"><%= Faker::Lorem.word.capitalize %></a></li>
    <li><a href="#"><%= Faker::Lorem.word.capitalize %></a></li>
    <li><a href="#"><%= Faker::Lorem.word.capitalize %></a></li>
  </ul>

sub_menu: |
  <ul>
    <li class="active"><a href="#"><%= Faker::Lorem.word.capitalize %></a></li>
    <li><a href="#"><%= Faker::Lorem.word.capitalize %></a></li>
    <li><a href="#"><%= Faker::Lorem.word.capitalize %></a></li>
    <li><a href="#"><%= Faker::Lorem.word.capitalize %></a></li>
    <li><a href="#"><%= Faker::Lorem.word.capitalize %></a></li>
  </ul>

ancestor_menu: |
  <% pages = %w(Page1 Page2 Page3 Page4 Page5) %>
  <ul>
    <% pages.each do |page| %>
      <li><%= page %></li>
    <% end %>
  </ul>
```