# Hammer

## bash config

    ESC_SEQ="\x1b["
    COL_RESET=$ESC_SEQ"39;49;00m"
    COL_RED=$ESC_SEQ"31;01m"
    COL_GREEN=$ESC_SEQ"32;01m"
    COL_YELLOW=$ESC_SEQ"33;01m"
    COL_BLUE=$ESC_SEQ"34;01m"
    COL_MAGENTA=$ESC_SEQ"35;01m"
    COL_CYAN=$ESC_SEQ"36;01m"

    function hammer {
        if [ $# -eq 0 ]
            then
                echo -e "${COL_RED}Dropping the hammer on cleanslate_themes!!!${COL_RESET}";
            else
                echo -e "${COL_RED}Dropping the hammer on ${1}!!!${COL_RESET}";
        fi
        rvm use ruby-1.9.3-p484@hammer && cd ~/Sites/hammer/hammer/ && ruby hammer_server.rb ~/Sites/cleanslate_themes/$@;
    }
    

## Mock Data Example

Mock data can use Faker objects: https://github.com/stympy/faker

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