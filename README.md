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

    editable_region:
      department-summary__header--how-do-i: "Spread the Word to End the Word."
      department-summary__main--how-do-i: "As the Division for Diversity, Equity and Inclusion, we are responsible for ensuring students and employees with disabilities have equal access to all aspects of the University which makes us an integral part of the disability community. We are joining with various organizations dedicated to improving the lives of individuals with intellectual disabilities by joining the national campaign called “Spread the Word to End the Word.” This campaign is an ongoing effort by two organizations, Special Olympics and Best Buddies, to raise the consciousness of society about the demeaning and hurtful effects of the word “retard(ed)”. The campaign asks people to pledge to stop saying the R-word as a starting point toward creating more accepting attitudes and communities for all people."
      contact: |
        <p>1085 Van Voorhis Road Suite 250 | P.O. Box 6202<br>Morgantown,
        <span class="caps">WV 26506</span>-6202<br>Phone: 304.293.5600 | Fax: 304.293.8279<br>Email:
        <a href="mailto:diversity@mail.wvu.edu">diversity@mail.wvu.edu</a></p>