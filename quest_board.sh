#!/usr/bin/env bash

mapfile -t first_names_list < firstnames.txt
mapfile -t last_names_list < lastnames.txt

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


reset_quest=true
output_random_rank=0

declare -gA random_quest_0_data=()
declare -gA random_quest_1_data=()
declare -gA random_quest_2_data=()
declare -gA in_progress_random_dungeon=()

time_stamp(){
epoch_seconds=$(date +%s)
reset_quest_timer=10
base_epoch_seconds=$(( epoch_seconds + reset_quest_timer ))
}

reset_quest_handler(){
    current_epoch_seconds=$(date +%s)
    if (( current_epoch_seconds > base_epoch_seconds ));then 
        reset_quest=true
        time_stamp
    else
        reset_quest=false
    fi    
}

random_theme_picker(){
for ((i=0;i<3;i++)); do
local random_theme_idx=$(( RANDOM % ${#all_themes[@]} ))
local random_theme="${all_themes[$random_theme_idx]}"
local for_display_theme="${random_theme^^}"
for_display_theme="${for_display_theme//_/ }"

(( i == 0 )) && random_quest_0_data[theme_display]="${for_display_theme}" && random_quest_0_data[theme]="${random_theme}"
(( i == 1 )) && random_quest_1_data[theme_display]="${for_display_theme}" && random_quest_1_data[theme]="${random_theme}"
(( i == 2 )) && random_quest_2_data[theme_display]="${for_display_theme}" && random_quest_2_data[theme]="${random_theme}"
done
}

random_rank_gen(){
local rank=1

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
    elif (( rank >= 1 && rank <= 5 )); then
        local min=$(( rank - 1 ))
        local max=$(( rank + 1 ))
        rank=$(( RANDOM % ( max - min + 1 ) + min ))
    elif (( rank == 6 )); then
        rank=$(( RANDOM % 2 + 5 ))
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

    local -n ref_rank_data="random_quest_${i}_data"

    ref_rank_data[rank]="${rank}"

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

random_name_generator(){

for ((i=0;i<3;i++));do    
    local firstname_idx=$(( RANDOM % ${#first_names_list[@]} ))
    local firstname="${first_names_list[$firstname_idx]}"
    local lastname_idx=$(( RANDOM % ${#last_names_list[@]} ))
    local lastname="${last_names_list[$lastname_idx]}"
    local fullname="${firstname} ${lastname}"

    (( i == 0)) && random_quest_0_data[rescue_name]="${fullname^^}"
    (( i == 1)) && random_quest_1_data[rescue_name]="${fullname^^}"
    (( i == 2)) && random_quest_2_data[rescue_name]="${fullname^^}"
done
}

stupid_plural_s_checker(){
(( ${random_quest_0_data[material_amount]} > 1 )) && random_quest_0_data[amount_is_plural]="S"
(( ${random_quest_1_data[material_amount]} > 1 )) && random_quest_1_data[amount_is_plural]="S"
(( ${random_quest_2_data[material_amount]} > 1 )) && random_quest_2_data[amount_is_plural]="S"
}

type_display_generator(){

[[ "${random_quest_0_data[type]}" == "COLLECT" ]] && random_quest_0_data[type_display]="COLLECT ${random_quest_0_data[material_amount]} \"${random_quest_0_data[material]}${random_quest_0_data[amount_is_plural]}\" IN THE-\n"
[[ "${random_quest_1_data[type]}" == "COLLECT" ]] && random_quest_1_data[type_display]="COLLECT ${random_quest_1_data[material_amount]} \"${random_quest_1_data[material]}${random_quest_1_data[amount_is_plural]}\" IN THE-\n"
[[ "${random_quest_2_data[type]}" == "COLLECT" ]] && random_quest_2_data[type_display]="COLLECT ${random_quest_2_data[material_amount]} \"${random_quest_2_data[material]}${random_quest_2_data[amount_is_plural]}\" IN THE-\n" 

[[ "${random_quest_0_data[type]}" == "CLEAR ALL MONSTERS" ]] && random_quest_0_data[type_display]="CLEAR ALL MONSTERS IN THE-\n"
[[ "${random_quest_1_data[type]}" == "CLEAR ALL MONSTERS" ]] && random_quest_1_data[type_display]="CLEAR ALL MONSTERS IN THE-\n"
[[ "${random_quest_2_data[type]}" == "CLEAR ALL MONSTERS" ]] && random_quest_2_data[type_display]="CLEAR ALL MONSTERS IN THE-\n"

[[ "${random_quest_0_data[type]}" == "RESCUE" ]] && random_quest_0_data[type_display]="RESCUE ${random_quest_0_data[rescue_name]} IN THE-\n"
[[ "${random_quest_1_data[type]}" == "RESCUE" ]] && random_quest_1_data[type_display]="RESCUE ${random_quest_1_data[rescue_name]} IN THE-\n"
[[ "${random_quest_2_data[type]}" == "RESCUE" ]] && random_quest_2_data[type_display]="RESCUE ${random_quest_2_data[rescue_name]} IN THE-\n"

}

take_quest() {
    local quest_num="$1"
    local -n quest_data

    case "$quest_num" in
        1) quest_data=random_quest_0_data ;;
        2) quest_data=random_quest_1_data ;;
        3) quest_data=random_quest_2_data ;;
        *) return 1 ;;
    esac

    for key in "${!quest_data[@]}"; do
        in_progress_random_dungeon["$key"]="${quest_data[$key]}"
    done

    random_in_progress=true
}

read_qb() {
    while true; do
        read -r -p "Take Quest #: " quest_choice

        if [[ -z "$quest_choice" ]]; then
            echo "Enter a quest number or type 'b' or 'back' to quit using the quest board"
            continue
        fi

        quest_choice="${quest_choice,,}"
        return
    done
}

confirm_quest() {
    local confirm_q
    local q_choice="$1"

    while true; do
        read -r -p "Accept Quest $q_choice? Y)es, N)o: " confirm_q

        if [[ -z "$confirm_q" ]]; then
            echo "Type yes or no."
            continue
        fi

        confirm_q="${confirm_q,,}"

        case "$confirm_q" in
            y|yes)
                take_quest "$q_choice"
                return
                ;;
            n|no)
                return
                ;;
            b|back)
                state="nav"
                ;;
            *)
                echo "Type yes or no."
                ;;
        esac
    done
}

press_any_to_continue() {
        read -rsn1 -p "Press any key to continue..."
        echo
}

#main shit

time_stamp

quest_board_handler() {

    if [[ "${reset_quest}" == true ]];then

        random_theme_picker
        random_rank_gen
        random_quest_type_generator
        collect_generator
        stupid_plural_s_checker
        random_name_generator
        type_display_generator
        reset_quest_handler
    else
        reset_quest_handler
    fi

    clear

    echo -e "              QUEST BOARD              \n\n"
    echo "it's currently ${current_epoch_seconds} quest will reset at ${base_epoch_seconds}"
    echo -e "QUEST [1]    RANK:${random_quest_0_data[rank]}\n${random_quest_0_data[type_display]}${UNDERLINE}${random_quest_0_data[theme_display]} ${RESET}\n"
    echo -e "QUEST [2]    RANK:${random_quest_1_data[rank]}\n${random_quest_1_data[type_display]}${UNDERLINE}${random_quest_1_data[theme_display]} ${RESET}\n"
    echo -e "QUEST [3]    RANK:${random_quest_2_data[rank]}\n${random_quest_2_data[type_display]}${UNDERLINE}${random_quest_2_data[theme_display]} ${RESET}\n"
    echo
    echo "R)echeck"
    echo -e "B)ack\n\n"
    echo -e "Active Quest: RANK:${in_progress_random_dungeon[rank]}\n${in_progress_random_dungeon[type_display]}${UNDERLINE}${in_progress_random_dungeon[theme_display]} ${RESET}\n"

    read_qb

    case $quest_choice in
        1|2|3) 
        if [[ "${random_in_progress}" == false ]]; then
            confirm_quest "$quest_choice"
        else
            echo "You can only have one side quest at a time"
            press_any_to_continue
        fi 
        ;;
        r|recheck) : ;;
        b|back)
        state="nav"
        clear
        desc_newline
        ;;
        *) echo "Make a valid choice" && read_qb && return ;;
    esac

}