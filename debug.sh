#!/usr/bin/env bash

source text_effects.sh
source room_descriptions.sh
random_quest_0=""
random_quest_1=""
random_quest_2=""

random_theme_picker(){
for ((i=0;i<3;i++)); do
local random_theme_idx=$(( RANDOM % ${#all_themes[@]} ))
local random_theme="${all_themes[$random_theme_idx]}"
local for_display_theme="${random_theme^^}"
for_display_theme="${for_display_theme//_/ }"

(( i == 0 )) && random_quest_0="${for_display_theme}"
(( i == 1 )) && random_quest_1="${for_display_theme}"
(( i == 2 )) && random_quest_2="${for_display_theme}"
done
}

random_theme_picker

clear

echo -e "              QUEST BOARD              \n\n"

echo -e "${UNDERLINE} ${random_quest_0}${RESET}\n"
echo -e "${UNDERLINE} ${random_quest_1}${RESET}\n"
echo -e "${UNDERLINE} ${random_quest_2}${RESET}\n"

