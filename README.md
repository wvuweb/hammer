# Hammer

Hammer is a theme development tool for the [CleanSlate](http://cleanslate.wvu.edu/ "CleanSlate") CMS template rendering engine. Hammer was created to help you iterate quickly on themes and template markup.

Hammer is **NOT** for content creation.

## Install & Usage

Please install via [Hammer-VM](https://github.com/wvuweb/hammer-vm)

## Interested? Need Help? Read more..

Visit the wiki for more information:

[Hammer Wiki](https://github.com/wvuweb/hammer/wiki)

### Development Dependencies

These dependencies are only needed if you are developing against Hammer directly

* Ruby 2.4
* Bundler Gem `gem install bundler`

### Mock Data File

Hammer uses a YAML file to 'mock' content data structures needed for cleanslate templates.

[`mock_data.yml`](https://github.com/wvuweb/hammer/wiki/Mock-Data#example-of-a-mock_datayml-file)

### Mock Data Documentation

```YAML
edit_mode: true                                 # edit mode                   -- accepts true | false
                                                # edit mode allows you to hide and show content based on context
                                                # <r:edit_mode_only>
                                                #   <p>This only shows in the editor mode of CleanSlate</p>
                                                # </r:edit_mode_only>

shared_themes:                                  # shared_themes are defined by
  "theme-name":                                 # <r:partial name="file/path" theme="theme-name"/>
    "file/path": folder                         # theme-name                  -- accepts quoted string
  "theme-name-2":                               # file/path                   -- accepts quoted file path string
    "file/path": folder                         # folder                      -- accepts quoted string  
    "file/path2": folder

editable_region:                                # editable_region are defined by
  region: String                                # <r:editable_region name="region" />
  region2: String                               # region                      -- accepts a string or | pipe character followed by HTML
                                                # example:
                                                # editable_region:
                                                #   region: |
                                                #     <p>Hello World!</p>

site:                                           # site is defined by any attributes your site would hold in CleanSlate
  id: 26                                        # id <r:site:id />            -- accepts an integer
  name: String                                  # name <r:site:name />        -- accepts a string
  domain: example.wvu.edu                       # domain <r:site:domain />    -- accepts a string
  data:                                         # data is defined by any custom data your page would hold in CleanSlate
    data_key: data_value                        # <r:site:data name="data_key" />
    data_key_2: data_value_2                    # data_key is the name of the custom data in page properties which is defined
                                                # in your templates front matter configuration
                                                # data_value is any value you wish to expose
root: true                                      # root tag is used to set the context for loops
                                                # <r:root />                  -- accepts true | false

page:                                           # page is defined by any attribute a page would hold in CleanSlate
  id: 1                                         # <r:page:id />               -- accepts an integer
  name: String                                  # <r:page:name />             -- accepts a string
  slug: string-dashed-notation                  # <r:page:slug />             -- accepts a string in dash notation
  meta_description: String                      # <r:page:meta_description /> -- accepts a string
  title: String                                 # <r:page:title />            -- accepts a string
  alternate_name: String                        # <r:page:alternate_name />   -- accpets a string
  depth: 1                                      # <r:page:depth />            -- accepts an integer
  updated_at: Jan 1st 2015 2:30PM               # <r:page:updated_at />       -- accepts a date string
  created_at: two weeks ago                     # <r:page:created_at />       -- accepts a date string
  published_at: now                             # <r:page:published_at />     -- accepts a date string
  data:                                         # data is defined by any custom data your page would hold in CleanSlate
    data_key: data_value                        # <r:data name="data_key" />
    data_key_2: data_value_2                    # data_key is the name of the custom data in page properties which is defined
                                                # in your templates front matter configuration
                                                # data_value is any value you wish to expose
  content:                                      # content attribute is for supporting loops in which a page
    region_name: String                         # may be dynamically building content from child pages or <r:get_page />
                                                # <r:page:if_has_content_for name="region_name" />
                                                # <r:page:unless_has_content_for name="region_name" />
pages:                                          # pages allow you to mock addtional pages to be used in page loops
  - id: 2                                       # such as <r:children /> <r:ancestors /> <r:decendants /> <r:siblings />
    name: String                                # each page set is seperated by a dash to create an Array of pages
    ...                                         # pages can contain all the data that the "page" key above can
  - id: 3
    ...
  - id: 4
    ...

if_page_depth_eq: 1                             # <r:if_page_depth_eq page_depth="1"/> test for page depth equal to value
if_page_depth_gt: 1                             # <r:if_page_depth_gt page_depth="1"/> test for page depth greater than value

site_menu: String                               # site menu allows you to override the html generated if you have a pages block
                                                # <r:site_menu />             -- accepts a string or | pipe character followed by HTML
                                                # example:
                                                # site_menu: |
                                                #   <ul>
                                                #     <li class="active"><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #   </ul>

sub_menu: String                                # sub_menu allows you to override the auto generated html created from the pages block
                                                # or the generic menu that gets output if you do not have a pages block.
                                                # <r:sub_menu />              -- accepts a string or | pipe character followed by HTML
                                                # example:
                                                # sub_menu: |
                                                #   <ul>
                                                #     <li class="active"><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #   </ul>

ancestor_menu: String                           # ancestor_menu allows you to override the auto generated html created from the pages block
                                                # or the generic menu that gets output if you do not have a pages block.
                                                # <r:ancestor_menu/>          -- accepts a string or | pipe character followed by HTML
                                                # example:
                                                # sub_menu: |
                                                #   <ul>
                                                #     <li class="active"><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #     <li><a href="#">Page</a></li>
                                                #   </ul>

breadcrumbs: String                             # breadcrumbs takes a string of HTML that outputs breadcrumb structure
                                                # breadcrumbs: |
                                                #   <ul class="wvu-breadcrumbs__crumbs">
                                                #     <li><a href="#">Home</a></li>
                                                #     <li class="active">Page</li>
                                                #   </ul>

files:                                          # files contains all the data for any of the <r:files|file /> tags
  - filename: String                            # files is an Array of files seperated by a dash
    name: String
    title: String
    alt_text: String
    download_url: String
    image_url: String
  - ...

blogs:                                          # blogs contains all the data for the <r:blog:{method} /> tags
  - id: Integer                                 # blogs contains an Array of blogs each blog set is seperated by a dash
    name: String                                # <r:blog:name />             -- accepts a string
                                                # blog articles much like pages are a repeating group of content for each article
    articles:                                   # each article is seperated by a dash  
      - article:                                # <r:blog:articles /> loops can access the following data in a <r:each />
        name: String                            # <r:article:name />          -- accepts a string
        title: String                           # <r:article:title />         -- accepts a string
        created_by:                             # <r:article:author_full_name />  -- accepts two other objects  
          first_name: String                    # <r:article:author_first_name /> -- accepts a string
          last_name: String                     # <r:article:author_last_name />  -- acccpts a string
        content:                                # content attribute is for supporting loops in which a blog article
          region_name: String                   # may be dynamically built using content regions from the article
                                                # <r:article:content name="region_name" />  
        published_at: 2 days ago                # <r:article:published_at />  -- accepts a date string
      - article:
        ...
      - article:
        ...
  - id: 2
    name: String
    ...
```

## Developer notes
Changelog uses [Github Changelog Generator](https://github.com/github-changelog-generator/github-changelog-generator)

[Generate a token](https://github.com/settings/tokens/new?description=GitHub%20Changelog%20Generator%20token) use in the command below in the project root.

`github_changelog_generator wvuweb/hammer --token {insert your token here} --future-release {release_version}`
