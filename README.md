# Hammer

Hammer is a theme development tool for the [CleanSlate](http://cleanslate.wvu.edu/ "CleanSlate") CMS template rendering engine. Hammer was created to help you iterate quickly on themes and template markup. Hammer is  NOT for content creation.

Hammer is similar to [Mock Builder v2](https://github.com/wvuweb/mock_builder "Mock Builder v2") for [Slate](http://slatecms.wvu.edu/ "Slate"), but has many differences due to the many differences in [CleanSlate](http://cleanslate.wvu.edu/ "CleanSlate"). If you are familiar with [Mock Builder v2](https://github.com/wvuweb/mock_builder "Mock Builder v2") you should be able to quickly get up and running with Hammer.

### Using Hammer

1. Open Terminal and type `hammer`.
1. Open your browser and go to [http://localhost:2000](http://localhost:2000).


###Dependencies

* Ruby 1.9.3-p484


###Mac OSX Installation

1. If you don't already have one, go to `~/Sites/` and make a folder called `cleanslate_themes`. You can do this via OSX Finder or via the following command in Terminal:
    *  `cd ~/Sites/ && mkdir cleanslate_themes`
        * To use Hammer, **all the themes you want to test locally must reside in the `cleanslate_themes` folder**.
        * If you have miscellaneous CleanSlate themes in your `~/Sites/` directory, it would be best to re-`git clone` those themes into the `cleanslate_themes` folder.
1. Install [Bundler](http://bundler.io/) if you don't already have it:
    * `gem install bundler`
        * If you get a "Permission denied" error of some sort, run `sudo gem install bundler` and enter your computer's password when prompted.
1. Install RVM: [Ruby Version Manager](http://rvm.io/ "Ruby Version Manager") via Terminal
    * **Note:** If you already have RVM installed due to a previous installation of [Mock Builder v2](https://github.com/wvuweb/mock_builder "Mock Builder"), skip to the next step.
    * `\curl -sSL https://get.rvm.io | bash -s stable`
    * Next, run: `source ~/.rvm/scripts/rvm`
        * Occasionally, RVM will ask you to run a few other commands. After installing, if it asks you to run other commands, please do so!
    * Next type `rvm requirements` and hit enter.
        * Installing RVM could take a while (30 minutes to 1.5 hours depending). Please be patient.
1. After RVM finishes installing, completely quit and reopen Terminal.
1. Clone the Hammer repo into your `~/Sites/` directory:
    * `cd ~/Sites/ && git clone https://github.com/wvuweb/hammer.git`
        * If you get `-bash: git: command not found` when you run `git clone`, go [install Git](http://git-scm.com/), then re-run the above command after quitting and reopening terminal.
1. Change directory to the root directory of hammer
    `cd ~/Sites/hammer/`
1. If RVM prompts you for a missing ruby install run the following: 
    * `rvm install 1.9.3-p484@hammer`
1. Then run 
    * `bundle install`
1. Next create a alias in your profile:
    * Use the following commands in Terminal to open .bash_profile `cd ~ && open -a TextEdit .bash_profile` or .profile `cd ~ && open -a TextEdit .profile` (depending on which one you use). 
        * If you don't know which file you use, paste the alias listed in the [bash config section](https://github.com/wvuweb/hammer/blob/master/README.md#bash-config) into **both** files (.bash_profile and .profile).
    * Copy and paste the alias listed in the [bash config section](https://github.com/wvuweb/hammer/blob/master/README.md#bash-config) into one or both of those files.
    * Save and quit TextEdit.
1. Completely quit Terminal. Then reopen Terminal and type `hammer`.
1. Visit `http://localhost:2000` in your browser. This will show you the root of Hammer.
1. In your `cleanslate_themes` folder, `git clone` the [code](https://stash.development.wvu.edu/projects/CST/repos/cleanslate-toolkit/browse) and [cleanslate-toolkit](https://stash.development.wvu.edu/projects/CST/repos/code/browse) themes.
    * `cd ~/Sites/cleanslate_themes`
    * `git clone https://stash.development.wvu.edu/scm/cst/code.git`
    * `git clone https://stash.development.wvu.edu/scm/cst/cleanslate-toolkit.git`
    * If you already have a CleanSlate theme in [Stash](https://stash.development.wvu.edu/projects/CST), go ahead and clone it too.
1. Refresh `http://localhost:2000` in your browser. You'll see your themes. Navigate to a page template to view it locally in your browser.
    * You'll notice the WVU masthead and shared footer are missing. A `mock_data.yml` file will fix this.
1. Congrats, you're up and running! You'll definitely want a `mock_data.yml` file. Keep reading to see how to get that set up.

#### bash config

Copy and paste the following lines into your `.bash_profile` or `.profile`

```
# Hammer: https://github.com/wvuweb/hammer
function hammer {
  rvm use ruby-1.9.3-p484@hammer && cd ~/Sites/hammer/hammer/ && ruby hammer_server.rb $@;
}
```

## Mock Data Example

**Warning:** your text editor must be set to space based tabs at (2 spaces) or you will have issues editing your `mock_data.yml` file

If you are familar with [Mock Builder v2](https://github.com/wvuweb/mock_builder "Mock Builder v2") this `mock_data.yml` file will look familar if not identical to your previous usage.  

There are some fundemental differences however.

***livereload*** key is an Advanced topic covered in further detail in the [Wiki](http://github.com/wvuweb/hammer/wiki "Link this to the wiki").  With this key you can enable javascript task runners such as grunt and gulp, to reload the page as you develop and save files.

***browsersync*** key is an Advanced topic covered in further detail in the [Wiki](http://github.com/wvuweb/hammer/wiki "Link this to the wiki").  With this key you can enable javascript task runners such as grunt and gulp, to reload the page as you develop.  BrowserSync advantage over livereload is that it allows a connection to other devices through sockets and a shared internet connection allowing you to see your updates on a mobile phone and tablet as you develop. 

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

***blog*** tags are still a work in progress. With that said the mock data example below will give you basic articles to view your design. Any advanced usage of blog tags may result in less then desirable results. Blog Tags included in this are as follows:

`<r:blog:articles limit="{$limit}" page="{$page}" tags="{$tags}" tags_op="{$tags_op}" year="{$year}" month="{$month}" day="{$day}">`
`<r:if_no_articles/>` 
`<r:if_articles/>`
`<r:select_html/>` `<r:pagination/>` and other related supporing tags.

Hammer `mock_data.yml` can also use Ruby code (see ancestor menu example below) to [manipulate strings](http://www.tutorialspoint.com/ruby/ruby_strings.htm "Ruby Strings") or create menus as well as Faker objects: <https://github.com/stympy/faker> to auto generate words, paragraphs and sentences.

**Example:** Mock data file for cleanslate/hammer

```yaml
livereload: false
browsersync: false
browsersync-data: |
  var head = document.getElementsByTagName('head')[0];
  var script = document.createElement('script');
  script.setAttribute("defer", "defer");
  script.type = 'text/javascript';
  var src= '//HOST:3000/socket.io/socket.io.js';
  script.src = src.replace(/HOST/g, location.hostname);
  head.appendChild(script);

  var head = document.getElementsByTagName('head')[0];
  var script = document.createElement('script');
  script.setAttribute("defer", "defer");
  script.type = 'text/javascript';
  var src= '//HOST:3001/client/browser-sync-client.0.9.1.js';
  script.src = src.replace(/HOST/g, location.hostname);
  head.appendChild(script);

shared_themes:
  layouts__masthead--v1: "code"
  layouts__footer__contact--v1: "code"
  layouts__footer__credits--v1: "code"
  layouts__footer__icons--v1: "code"
  layouts__browser-update-org--v1: "code"

editable_region:
  main: This is content for the main editable region. Change what it says in the mock_data.yml file.
  sidebar: Sidebar stuff.
  contact: |
    <p><strong>Division of Virginia West Advancement</strong></p>
    <p>1111 WVU Road Suite 250 | P.O. Box 6202 | Morgantown, WV 26506-6202</p>
    <p><strong>Phone:</strong> 304.293.5600 | <strong>Fax:</strong> 304.293.8279 | <strong>Email:</strong> <a href="mailto:firstname.lastname@mail.wvu.edu">firstname.lastname@mail.wvu.edu</a></p>

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
  
blog:
  name: Blog Name
  articles:
    - article: 
      name: <%= Faker::Lorem.sentence(1) %>
      title: <%= Faker::Lorem.sentence(1) %>
      created_by: 
        first_name: <%= Faker::Name.first_name %>
        last_name: <%= Faker::Name.last_name %>
      content: |
        <p><%= Faker::Lorem.paragraph(2) %></p>
        <p><%= Faker::Lorem.paragraph(5) %></p>
        <p><%= Faker::Lorem.paragraph(3) %></p>
      published_at: 2 days ago
    - article:
      name: <%= Faker::Lorem.sentence(1) %>
      title: <%= Faker::Lorem.sentence(1) %>
      created_by: 
        first_name: <%= Faker::Name.first_name %>
        last_name: <%= Faker::Name.last_name %>
      content: |
        <p><%= Faker::Lorem.paragraph(2) %></p>
        <p><%= Faker::Lorem.paragraph(5) %></p>
        <p><%= Faker::Lorem.paragraph(3) %></p>
      published_at: 4 days ago
    - article:
      name: <%= Faker::Lorem.sentence(1) %>
      title: <%= Faker::Lorem.sentence(1) %>
      created_by: 
        first_name: <%= Faker::Name.first_name %>
        last_name: <%= Faker::Name.last_name %>
      content: |
        <p><%= Faker::Lorem.paragraph(2) %></p>
        <p><%= Faker::Lorem.paragraph(5) %></p>
        <p><%= Faker::Lorem.paragraph(3) %></p>
      published_at: 5 days ago
```
