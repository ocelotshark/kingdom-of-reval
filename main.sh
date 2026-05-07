#!/usr/bin/env bash

#INIT EXTERNAL

source text_effects.sh
source parsers.sh
source navigation.sh
source handlers.sh
source chatarrays.sh
source room_descriptions.sh
source enemies.sh
source spells.sh
source flee.sh
source skills.sh
source dungeon_gen.sh
source character_screen.sh
source lookarrays.sh
source items.sh
source inventory.sh
source dumb_functions.sh

#-------------------------
#INIT VARS
#-------------------------

name=""
player_rank="bronze"
class=""
race=""

location="room_start"
location_tmp="$location"

lvl=1
lvl_points=10
player_xp=0
xp_to_next_lvl=100

strength=0
determination=0
intelligence=0

base_max_health=100
max_health=100
player_health=100

base_max_mana=60
max_mana=60
player_mana=60
mana_recovery=5

base_attack=1
player_attack=0
base_defense=0
player_skill_points=0

player_reputation=50

spawn=true
combat_rank="F"
base_rank="F"

player_skills=("Cleave" "Shadow Step")
player_spells=("Fireball" "Magic Missile")
player_uffs=()

in_random_dungeon=false
flee_success=false
first_load=true
draw_dungeon=true
state="nav"
start_combat=true
char_creation_done=false
prev_state="nav"
bonus_health=0
screen_flashing=true

  case $1 in
    -sn|--skipn)
      echo "First Load = False"
      echo "State = Nav"
      echo "Room = Tutorial End"
      name="Debugger"
      class="warrior"
      race="human"
      char_creation_done="finished"
      location="guild_hall_center"
      first_load=false
      state="nav"
      ;;
    -sc|--skipc)
      echo "First Load = False"
      echo "State = Combat"
      first_load=false
      state="combat"
      ;;

  esac


#-------------------------
#START GAME
#-------------------------

clear
desc_room


#-------------------------
#DISPATCHER
#-------------------------

while true; do

#-------------------------
#NAV STATE
#-------------------------


    while [[ "${state}" == "nav" ]]; do
    story_mode_parser

    done

#-------------------------
#CHAT STATE
#-------------------------


    while [[ "${state}" == "chat" ]]; do
    chat_parser

    done

#-------------------------
#COMBAT STATE
#-------------------------

    while [[ "${state}" == "combat" ]]; do

    if [[ ${start_combat} = true ]]; then
        clear
        combat_start_handler
    fi

    set_enemy_attack
    enemy_display
    comb_tui

    read -r -p "SELECT AN ACTION: " action
    action="${action,,}"
    combat_handler
    clear

    done   

#-------------------------
#CHARACTER SCREEN STATE
#-------------------------

while [[ "${state}" == "char_screen" ]] do
char_screen_tui

done

done