#!/usr/bin/env bash

source text_effects.sh
source room_descriptions.sh

    quest_material_list=(
        "GOBLIN EAR"
        "TROLL TOENAIL"
        "MANA CRYSTAL"
        "BOTTLED TEAR"
        "WHISPERING SHARD"
        "SCREAMING CRYSTAL"
        "GRAVEMOSS"
        "WITCHROOT"
        "BLOODMINT"
        "CEREMONIAL SPOON"
        "ANCIENT SCROLL"
        "CRACKED IDOL"
        "OMINOUS TEASPOON"
        "INSECT MOLT"
        "SLIME CORE"
)

random_quest_0=""
random_quest_1=""
random_quest_2=""
output_random_rank=0
base_rank="E"

declare -gA random_quest_0_data=()
declare -gA random_quest_1_data=()
declare -gA random_quest_2_data=()

random_theme_picker(){
for ((i=0;i<3;i++)); do
local random_theme_idx=$(( RANDOM % ${#all_themes[@]} ))
local random_theme="${all_themes[$random_theme_idx]}"
local for_display_theme="${random_theme^^}"
for_display_theme="${for_display_theme//_/ }"

(( i == 0 )) && random_quest_0="${for_display_theme}" && random_quest_0_data[theme]="${random_theme}"
(( i == 1 )) && random_quest_1="${for_display_theme}" && random_quest_1_data[theme]="${random_theme}"
(( i == 2 )) && random_quest_2="${for_display_theme}" && random_quest_2_data[theme]="${random_theme}"
done
}

random_rank_gen(){
    local rank=4

for ((i=0;i<3;i++)); do

    case $base_rank in
        "F") rank=0 ;; 
        "E") rank=1 ;; 
        "D") rank=2 ;; 
        "C") rank=3 ;; 
        "B") rank=4 ;; 
        "A") rank=5 ;; 
        "S") rank=6 ;;
    esac


    if (( rank == 0 )); then
        rank=$(( RANDOM % 2 ))
    elif [[ "${rank}" == [1-5] ]]; then
        local min=$(( rank - 1 ))
        local max=$(( rank + 1 ))
        rank=$(( RANDOM % ( max - min + 1 ) + min ))
    elif (( rank == 6 )); then
        rank=$(( RANDOM % ( 6 - 5 + 1) + min ))
    fi

    case $rank in
        0) rank="F" ;; 
        1) rank="E" ;; 
        2) rank="D" ;; 
        3) rank="C" ;; 
        4) rank="B" ;; 
        5) rank="A" ;; 
        6) rank="S" ;;
    esac

    (( i == 0)) && random_quest_0_data[rank]="${rank}"
    (( i == 1)) && random_quest_1_data[rank]="${rank}"
    (( i == 2)) && random_quest_2_data[rank]="${rank}"

done
}

random_quest_type_generator() {
    local random_quest_type=( "CLEAR ALL MONSTERS" "COLLECT" "RESCUE" )
    local quest
    for ((i=0;i<3;i++)); do
        quest_idx=$(( RANDOM % ${#random_quest_type[@]} ))
        quest="${random_quest_type[$quest_idx]}"

        (( i == 0)) && random_quest_0_data[type]="${quest}"
        (( i == 1)) && random_quest_1_data[type]="${quest}"
        (( i == 2)) && random_quest_2_data[type]="${quest}"
    done
}

collect_generator(){

for ((i=0;i<3;i++));do
    local amount=$(( RANDOM % 10 + 1 ))
    local material_idx=$(( RANDOM % ${#quest_material_list[@]} ))
    local material_val="${quest_material_list[$material_idx]}"

    (( i == 0)) && random_quest_0_data[material]="${material_val}" && random_quest_0_data[material_amount]="${amount}"
    (( i == 1)) && random_quest_1_data[material]="${material_val}" && random_quest_1_data[material_amount]="${amount}"
    (( i == 2)) && random_quest_2_data[material]="${material_val}" && random_quest_2_data[material_amount]="${amount}"
done

}

type_display_generator(){

[[ "${random_quest_0_data[type]}" == "COLLECT" ]] && random_quest_0_data[type_display]="COLLECT ${random_quest_0_data[material_amount]} \"${random_quest_0_data[material]}\" IN THE\n"
[[ "${random_quest_1_data[type]}" == "COLLECT" ]] && random_quest_1_data[type_display]="COLLECT ${random_quest_1_data[material_amount]} \"${random_quest_1_data[material]}\" IN THE\n"
[[ "${random_quest_2_data[type]}" == "COLLECT" ]] && random_quest_2_data[type_display]="COLLECT ${random_quest_2_data[material_amount]} \"${random_quest_2_data[material]}\" IN THE\n" 

[[ "${random_quest_0_data[type]}" == "CLEAR ALL MONSTERS" ]] && random_quest_0_data[type_display]="CLEAR ALL MONSTERS IN THE\n"
[[ "${random_quest_1_data[type]}" == "CLEAR ALL MONSTERS" ]] && random_quest_1_data[type_display]="CLEAR ALL MONSTERS IN THE\n"
[[ "${random_quest_2_data[type]}" == "CLEAR ALL MONSTERS" ]] && random_quest_2_data[type_display]="CLEAR ALL MONSTERS IN THE\n"

}

random_theme_picker
random_rank_gen
random_quest_type_generator
collect_generator
type_display_generator

clear

echo -e "              QUEST BOARD              \n\n"

echo -e "${random_quest_0_data[type_display]}${UNDERLINE}${random_quest_0} RANK:${random_quest_0_data[rank]}${RESET}\n"
echo -e "${random_quest_1_data[type_display]}${UNDERLINE}${random_quest_1} RANK:${random_quest_1_data[rank]}${RESET}\n"
echo -e "${random_quest_2_data[type_display]}${UNDERLINE}${random_quest_2} RANK:${random_quest_2_data[rank]}${RESET}\n"

