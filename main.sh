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

#-------------------------
#INIT VARS
#-------------------------

name="Wesley"
location="room_start"
location_tmp="$location"

max_health=100
player_health=100

max_mana=100
player_mana=100
mana_recovery=5

player_attack=5
player_defense=1
player_skill_points=6
spawn=true
combat_rank="F"

player_skills=("Cleave" "Shadow Step")
player_spells=("Fireball" "Magic Missile")
in_random_dungeon=false
flee_success=false
first_load=true



#-------------------------
#START GAME
#-------------------------

clear
desc_room
state="nav"
start_combat=true

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

done