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