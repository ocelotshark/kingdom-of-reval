#!/usr/bin/env bash

mapfile -t rescue_activities < rescue_npc_activities.txt

#enemy attack damage based on rank
f_max_damage=10
f_min_damage=1
e_max_damage=20
e_min_damage=4

check_for_material() {
if [[ "${in_progress_random_dungeon[type]}" == "COLLECT" ]];then 
    quest_object_here=false
    if (( has_material[$location] > 0 ));then
        echo "You find ${has_material[$location]} ${in_progress_random_dungeon[material],,}s here"
        quest_object_here=true
    else
        quest_object_here=false
    fi
fi
}

check_for_rescue() {
if [[ "${in_progress_random_dungeon[type]}" == "RESCUE" ]];then 
    quest_object_here=false
    if [[ "${in_progress_random_dungeon[rescue_location]}" == "${location}" ]];then
        local activity_idx=$(( RANDOM % "${#rescue_activities[@]}" ))
        local activity="${rescue_activities[$activity_idx]}"
        local display_name="${in_progress_random_dungeon[rescue_name],,}"
        local display_name_fix=""
        for word in $display_name;do
            display_name_fix+="${word^} "
        done
        display_name="${display_name_fix% }"
        echo "${display_name} ${activity}"
        quest_object_here=true
    else
        quest_object_here=false
    fi
fi
}

portal_enter(){
clear

printf "\n\n\n"
printf "Nothing remains.\n"

sleep 2

clear

printf "\n\n\n"
printf "A crimson sea swallows sight, sound, and thought.\n"

sleep 3
}

portal_screen(){
local input
local material="${in_progress_random_dungeon[material],,}"
material="${material//_/ }"
local person="${in_progress_random_dungeon[rescue_name],,}"
person="${person//_/ }"
local -a person_array=($person)
for i in "${!person_array[@]}"; do
    person_array[$i]="${person_array[$i]^}"
done
person="${person_array[*]}"

clear
printf "\t\t%b\n" "THE ${RED}${BLINK}PORTAL${RESET} FILLS YOUR VIEW"
printf "\n\n\n"
echo -e "Crimson ripples grow and multiply within the borders of the
oak-framed portal. You hear a low hum that vibrates through your
chest. A strange gravitational pull beckons you inward."
echo
case "${in_progress_random_dungeon[type]}" in
    "CLEAR ALL MONSTERS")
        echo -e "${ITALIC}A sickness grows on the other side of the portal.${RESET}"
    ;;
    "COLLECT")
        echo -e "${ITALIC}You need to find those ${material}s...
You wonder what they're used for.${RESET}"
    ;;
    "RESCUE")
        echo -e "${ITALIC}You catch glimpses of ${person}.
You could swear they looked back at you with hopeful eyes.${RESET}"
    ;;
    *)
        echo -e "${ITALIC}The portal churns silently.
Something waits beyond, but it remains hidden from you.${RESET}"
    ;;
esac
echo
echo "E)nter Portal"
echo "B)ack"
echo
while [[ -z "${input}" ]]; do
read -r -p "> " input
done

input="${input,,}"
case "${input}" in
    e|enter)
        portal_enter
        wait
        clear
        use_portal
        state="nav"
    ;;
    b|back)
        clear
        state="nav"
        flee_success=true
    ;;
    *)
    input=""
    ;;
esac
}

#-------------------------
#DESCRIBE ROOM
#-------------------------

desc_room() {
    [[ ${in_random_dungeon} == false ]] && echo -e "${room_desc[$location]}"
    [[ ${in_random_dungeon} == true ]] && theme_banner="${banner_title//_/ }" && theme_banner="${theme_banner^^}" && echo -e "\e[7m${theme_banner}\e[0m\n" && 
    [[ ${in_random_dungeon} == true ]] && echo "${random_dungeon_properties["$location,description"]}" && check_for_material && check_for_rescue && completed_quest_checker
 
    if [[ ${in_random_dungeon} == true ]]; then
        random_dungeon_spawner
        obv_exits=()
        obv_exit_checker_north
        obv_exit_checker_south
        obv_exit_checker_east
        obv_exit_checker_west
        exit_checker
        if [[ "${state}" != "combat" ]];then
            echo
            printf "%s • " "Obvious Exits: ${obv_exits[@]}"
        fi
    fi
}

combat_start_handler() {
        case $combat_rank in
            Z)
                z_rank_spawner DUMMY
            ;;

            E)
                e_rank_spawner #SEE ENEMIES.SH
            ;;

            F)
                f_rank_spawner #SEE ENEMIES.SH
            ;;
            
        esac

#-------------------------
#COMBAT INTRODUCTION HANDLER
#-------------------------

intro_handler() {

    if [[ $start_combat == true ]]; then
        lc_ename="${ename,,}" #lowercase
        lc_a_ename="${lc_ename}""_narrative" #add _narrative 
        lc_a_ename="${lc_a_ename// /_}"
        declare -n nar_enemy="${lc_a_ename}" #turn it into a ref
        random_3=$(( RANDOM % 3 ))
        random_nar="$lc_ename""_""$random_3"
        random_nar="${random_nar// /_}"
        action2="${nar_enemy[$random_nar]}"
        a_an_checker
        action1="You stand before $aan $ename"
    fi
    start_combat=false
    combat_menu="attack"
}
#EXECUTE
intro_handler

}

return_check(){

    if [[ ${flee_success} = true ]]; then
        desc_room
        if [[ "${in_random_dungeon}" == true ]];then 
            if [[ ${reverse_direction} != "blocked" ]];then 
                echo -e "\n${DIM}- You came from the $reverse_direction${RESET}"
            fi
        fi
        completed_quest_checker
        flee_success=false
        show_active_quest
    fi
}

desc_newline(){
    desc_room
    echo  
}

taste_here() {
    local taste_text="$1"
    desc_newline
    echo -e "${ITALIC}$taste_text${RESET}" 
}

hurt_player(){
    screen_flash
    local lose=$1
    (( player_health - lose > 0 )) && (( player_health -= lose ))
    (( player_health - lose <= 0 )) && state="dead"
}

#-------------------------
#SCREEN FLASH
#-------------------------

screen_flash() {

if [[ "${screen_flashing}" = true ]]; then 

printf '%b' "${WHITE_BG}"
sleep 0.08
printf '%b' "${RESET_BG}"
sleep 0.08
printf '%b' "${RED_BG}"
sleep 0.08
printf '%b' "${RESET_BG}"

fi
}


#-------------------------
#TASTE HANDLER
#-------------------------
clerk_lick_tries=0

taste_handler(){
    local noun="${noun// /_}"
    local simple_inventory=("${!player_inventory[@]}")
    local simple_equipment=("${player_equipment[@]}")
    local found=false

    case $noun in
        beer)noun="drink";;
        ale)noun="drink";;
        brew)noun="drink";;
        bar)noun="counter";;
    esac

    for i in "${simple_inventory[@]}"; do
        if [[ "$noun" == "$i" ]];then
            desc_room
            echo
            echo -e "${ITALIC}${taste_data[$noun]}${RESET}"
            found=true
            return
        fi
    done

    for i in "${simple_equipment[@]}"; do
        if [[ "$noun" == "$i" ]];then
            desc_room
            echo        
            echo -e "${ITALIC}${taste_data[$noun]}${RESET}"
            found=true
            return
        fi
    done
    case $noun in

    floor)
        taste_here "${generic_taste_data[floor_taste_$(( RANDOM % 10 ))]}"
        return
        ;;
    wall)
        taste_here "${generic_taste_data[wall_taste_$(( RANDOM % 10 ))]}"
        return
        ;;
    esac

    case $noun:$location in

    *clerk*:"guild_hall_center")
        clerk_lick
        return
        ;;
    *board*:"fandor_gh_bar")
        taste_here "${taste_data[trophy_board]}"
        return
        ;;
    *drink*:"fandor_gh_bar")
        taste_here "${taste_data[bar_drink]}"
        return
        ;;
    *counter*:"fandor_gh_bar")
        taste_here "${taste_data[bar_counter]}"
        return
        ;;
    *bartender*:"fandor_gh_bar")
        taste_here "${taste_data[bartender_taste]}"
        return
        ;;        
    esac
    
[[ "${found}" == false ]] && desc_room ; echo ; echo -e "${ITALIC}You can't taste that${RESET}"

}
#-------------------------
#RECOVER
#-------------------------
recover_mana() {
    local mana_add=$1
    if (( player_mana + mana_add <= max_mana ));then
        (( player_mana += mana_add ))
    else
        player_mana=$max_mana
    fi
}
recover_health() {
    local health_add=$1
    if (( player_health + health_add <= max_health ));then
        (( player_health += health_add ))
    else 
        player_health=$max_health
    fi
}

recover_skill_points() {
    local skill_add=$1
    local confirm

    if (( player_skill_points + skill_add > max_skill_points ));then
        desc_newline
        echo "Part or all of this item's restorative effects may be wasted."
        read -r -p "Are you sure you want to use it? (Y)es or (N)o: " confirm
        confirm="${confirm,,}"
            case $confirm in
                y|yes)
                    player_skill_points=$max_skill_points
                ;;
                n|no)
                    return 2
                ;;
            esac
    else
        (( player_skill_points += skill_add ))
    fi
             
}

#-------------------------
#DEFEND
#-------------------------
defend_handler() {
if (( player_defense > 0 )); then
defend_weight=$(( RANDOM % $player_defense + 2 ))
defended_damage=$(( eattack / defend_weight ))
defended_against=$(( eattack - defended_damage ))
action1="You defended against $defended_against pts! Focusing your mana is now $player_mana/$max_mana!"
action2="$ename hits you for $defended_damage"
player_health=$(( player_health - defended_damage ))
recover_mana $mana_recovery
else
action1="You have zero defense, you defend with hope. Hope isn't very good armor"
action2="$ename hits you for $eattack"
player_health=$(( player_health - $eattack ))
recover_mana $mana_recovery
fi
}

#-------------------------
#EXIT DUNGEON HANDLER
#-------------------------
exit_dungeon_handler(){

                if [[ "${in_random_dungeon}" == true ]]; then
                if [[ "${location}" == "${EXIT}" ]];then
                    if [[ "${in_progress_random_dungeon[state]}" == true ]];then #you on an uncompleted quest homie?
                        echo "If you leave the dungeon without completing the quest, it will be abandoned"
                        read -r -p "Are you sure you want to leave? Yes or No: " confirm_leave
                        echo
                        case $confirm_leave in
                            y|yes)
                                in_progress_random_dungeon=()
                                in_progress_random_dungeon[state]=false
                                reverse_direction=""
                                in_random_dungeon=false
                                combat_rank="${base_rank}"
                                state="nav"
                                location="${prev_nav_location}"
                                clear
                                desc_newline
                            ;;
                            n|no)
                                desc_newline
                            ;;
                            *)
                                desc_newline 
                                echo "Yes or No?"
                            ;;
                        esac
                    else #you aint on a quest homie
                        in_random_dungeon=false
                        state="nav"
                        location="${prev_nav_location}"
                        reverse_direction=""
                        desc_newline
                    fi
                else
                    desc_newline                
                    echo -e "${ITALIC}You search and search as if your life depends on it, but can't find an exit.${RESET}"
                fi
            else
            desc_newline 
            echo -e "${ITALIC}You search and search as if your life depends on it, but can't find an exit.${RESET}"
            fi

}

#-------------------------
#RANDOM DUNGEON NAVIGATION
#-------------------------

rdung_nav_checker_north() {
row="${location%%,*}"
col="${location##*,}"
row_check="$(( row - 1 ))"
nuu="${row_check},${col}"
valid=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nuu" == "${rooms[i]}" ]]; then
                        location="$nuu"
                        valid=true       
                        break
                    fi
                done
                [[ $valid = false ]] && echo "You can't go that way" && echo
}

rdung_nav_checker_south() {
row="${location%%,*}"
col="${location##*,}"
row_check="$(( row + 1 ))"
nuu="${row_check},${col}"
valid=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nuu" == "${rooms[i]}" ]]; then
                        location="$nuu"
                        valid=true
                        break       
                    fi
                done
                [[ $valid = false ]] && echo "You can't go that way" && echo
}

rdung_nav_checker_west() {
row="${location%%,*}"
col="${location##*,}"
col_check="$(( col - 1 ))"
nuu="${row},${col_check}"
valid=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nuu" == "${rooms[i]}" ]]; then
                        location="$nuu"
                        valid=true
                        break       
                    fi
                done
                [[ $valid = false ]] && echo "You can't go that way" && echo
}

rdung_nav_checker_east() {
row="${location%%,*}"
col="${location##*,}"
col_check="$(( col + 1 ))"
nuu="${row},${col_check}"
valid=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nuu" == "${rooms[i]}" ]]; then
                        location="$nuu"
                        valid=true       
                        break
                    fi
                done
                [[ $valid = false ]] && echo "You can't go that way" && echo
}

#-------------------------
#RANDOM DUNGEON OBVIOUS EXITS
#-------------------------

exit_checker(){

if [[ "${location}" == "${EXIT}" ]]; then
    valid=true
    obv_exits+=("${pf_REVERSE}Exit${pf_RESET}")    
fi

}

obv_exit_checker_north() {
row="${location%%,*}"
col="${location##*,}"
row_check="$(( row - 1 ))"
nuu="${row_check},${col}"
valid=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nuu" == "${rooms[i]}" ]]; then
                        valid=true
                        obv_exits+=("North")    
                    fi

                done
}

obv_exit_checker_south() {
row="${location%%,*}"
col="${location##*,}"
row_check="$(( row + 1 ))"
nuu="${row_check},${col}"
valid=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nuu" == "${rooms[i]}" ]]; then
                        valid=true
                        obv_exits+=("South")                                
                    fi

                done
}

obv_exit_checker_west() {
row="${location%%,*}"
col="${location##*,}"
col_check="$(( col - 1 ))"
nuu="${row},${col_check}"
valid=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nuu" == "${rooms[i]}" ]]; then
                        valid=true
                        obv_exits+=("West")                                 
                    fi

                done
}

obv_exit_checker_east() {
row="${location%%,*}"
col="${location##*,}"
col_check="$(( col + 1 ))"
nuu="${row},${col_check}"
valid=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nuu" == "${rooms[i]}" ]]; then
                        valid=true
                        obv_exits+=("East")    
                    fi

                done
}

#-------------------------
#GO VERB HANDLER
#-------------------------

go_handler() {
    if [[ "${in_random_dungeon}" = true ]]; then
        case $noun in
            
            "north")
                rdung_nav_checker_north
                desc_room
                reverse_direction="south"
            ;;

            "south")
                rdung_nav_checker_south
                desc_room                
                reverse_direction="north"

            ;;
            "west")
                rdung_nav_checker_west
                desc_room               
                reverse_direction="east"
            ;;

            "east")
                rdung_nav_checker_east
                desc_room                
                reverse_direction="west"
            ;;

            "exit")
                exit_dungeon_handler
            ;;

            *)
                reverse_direction="blocked"
            ;;
        esac
        
        if [[ ${reverse_direction} != "blocked" ]];then 
            echo -e "\n${DIM}- You came from the $reverse_direction${RESET}"
        fi
        quest_completed_text
        [[ ${draw_dungeon} == true ]] && echo && draw_dungeon
    fi

    story_navigation

}

#-------------------------
#SHOW ACTIVE QUEST
#-------------------------
show_active_quest() {
        if [[ "${in_random_dungeon}" == true ]] && [[ "${in_progress_random_dungeon[state]}" == true ]];then
            echo ; echo
            echo -e "Active Quest: RANK:${in_progress_random_dungeon[rank]}\n${in_progress_random_dungeon[type_display]}${UNDERLINE}${in_progress_random_dungeon[theme_display]} ${RESET}\n"
        fi
}

#-------------------------
#USE PORTAL
#-------------------------

use_portal(){
if (( $# == 0 ));then
    prev_nav_location="${location}" 
    if [[ "${random_in_progress}" == true ]]; then       
        combat_rank="${in_progress_random_dungeon[rank]}"
        in_random_dungeon=true
        case $combat_rank in
            "F") local width=4 ; local height=6 ;;
            "E") local width=6 ; local height=10 ;;
            "D") local width=10 ; local height=10 ;;
            "C") local width=12 ; local height=12 ;;
            "B") local width=12 ; local height=12 ;;
            "A") local width=15 ; local height=15 ;;
            "S") local width=20 ; local height=20 ;;
        esac
        dungeon_gen $width $height "${in_progress_random_dungeon[theme]}"
        #echo "${rooms[*]}"
        loca_index=$(( RANDOM % ${#rooms[@]} ))
        location="${rooms[loca_index]}"
        location_rd_prev="$location"
        desc_room
    else
        in_random_dungeon=true
        case $base_rank in
            "F") local width=4 ; local height=6 ;;
            "E") local width=6 ; local height=10 ;;
            "D") local width=10 ; local height=10 ;;
            "C") local width=12 ; local height=12 ;;
            "B") local width=12 ; local height=12 ;;
            "A") local width=15 ; local height=15 ;;
            "S") local width=20 ; local height=20 ;;
        esac
        dungeon_gen $width $height
        #echo "${rooms[*]}"
        loca_index=$(( RANDOM % ${#rooms[@]} ))
        location="${rooms[loca_index]}"
        location_rd_prev="$location"
        desc_room
    fi
else
    local width=$1
    local height=$2
    prev_nav_location="${location}" 
    if [[ "${random_in_progress}" == true ]]; then       
        combat_rank="${in_progress_random_dungeon[rank]}"
        in_random_dungeon=true
        dungeon_gen $width $height "${in_progress_random_dungeon[theme]}"
        #echo "${rooms[*]}"
        loca_index=$(( RANDOM % ${#rooms[@]} ))
        location="${rooms[loca_index]}"
        location_rd_prev="$location"
        desc_room
    else
        in_random_dungeon=true
        dungeon_gen $width $height
        #echo "${rooms[*]}"
        loca_index=$(( RANDOM % ${#rooms[@]} ))
        location="${rooms[loca_index]}"
        location_rd_prev="$location"
        desc_room
    fi
fi

#-------------------------
#TROPHY BOARD HANDLER
#-------------------------

}
trophy_board_handler(){
    clear
    echo -e "       ${BnR}TROPHY BOARD${RESET}"
    echo
    echo
    echo -e "${UNDERLINE}Your Kills${RESET}"
    for key in "${!enemy_kills[@]}"; do
        display_key="${key//_/ }"
        printf "%-16s %-3s %5s\n" "${display_key^^}" "-" "KILLS:${enemy_kills[$key]}"
    done
    echo -e "${UNDERLINE}                               ${RESET}"
    echo
    printf "Press any key to exit "
    read -rn 1
    clear
    state="nav"
    flee_success=true
    echo
}

#-------------------------
#LOOK VERB HANDLER
#-------------------------


look_handler() {

    case $noun in

        *)
            if [[ -z "${noun}" ]]; then #if player just types look
                desc_room
            fi
        ;;

    esac

    case $noun:$location in

        *clerk*:"guild_hall_center")
            echo "${npc_look[clerk_default]}"
        ;;
        "north":"guild_hall_center")
            echo "${npc_look[clerk_default]}"
        ;;        
        *desk*:"guild_hall_center")
            echo "${npc_look[clerk_default]}"
        ;;
        "south":"guild_hall_center")
            echo "${object_look[fandor_gh_door]}"
        ;;
        *door*:"guild_hall_center"|*door*:"fandor_gh_outside")
            echo "${object_look[fandor_gh_door]}"
        ;;
        "west":"guild_hall_center")
            echo "${object_look[fandor_gh_bar]}"
        ;;
        *bar*:"guild_hall_center")
            echo "${object_look[fandor_gh_bar]}"
        ;;
        *board*:"guild_hall_center")
            echo "${object_look[quest_board]}"
        ;;
        *board*:"fandor_gh_bar")
            echo "${object_look[trophy_board]}"
        ;;
        *portal*:"fandor_gh_outside")
            echo -e "${object_look[fandor_gh_portal]}"
        ;;
        *dummy*:"fandor_gh_outside")
            echo -e "${object_look[dummy_1]}"
        ;;        
        *)
            if [[ -n "${noun}" ]]; then #if its an unknown noun
                desc_room
                echo -e "${ITALIC}You don't see $noun${RESET}"
            fi

    esac      
}

#-------------------------
#TAKE VERB HANDLER
#-------------------------

update_room_after_take(){
    build_room_desc
    desc_room
    echo
    echo -e "${ITALIC}You take the $noun${RESET}"
}

nothing_to_take(){
    desc_room
    echo
    echo -e "${ITALIC}You don't see any $noun around here${RESET}"
}

rescue_handler(){
    if [[ "${in_progress_random_dungeon[type]}" == "RESCUE" ]];then
        if [[ "${quest_object_here}" == true ]]; then
            local rand_rescue_person="${in_progress_random_dungeon[rescue_name],,}"
            noun="${rand_rescue_person}"
            verb="take"
            take_handler
        else
            desc_newline
            echo "${in_progress_random_dungeon[rescue_name],,} isn't here!"
        fi
    else
        desc_newline
        echo "You need to be on a quest to rescue someone!"
    fi
}
take_handler() {

    local rand_quest_item="${in_progress_random_dungeon[material],,}"
    rand_quest_item="${rand_quest_item//_/ }"
    # read -ra rand_quest_keywords <<< "$rand_quest_item"
    local rand_rescue_person="${in_progress_random_dungeon[rescue_name],,}"

    case $noun in
        "${rand_quest_item}"|"${rand_quest_item}"s)
            desc_newline
            echo
            if [[ "${quest_object_here}" == true ]]; then
                for ((i=0;i<${has_material[$location]};i++)); do
                    add_item_handler "${in_progress_random_dungeon[material],,}"
                done
            (( in_progress_random_dungeon[material_collected] += has_material[$location] ))
            has_material[$location]=0
            clear
            update_room_after_take
            fi
            return
        ;;
        "${rand_rescue_person}")
            desc_newline
            echo
            if [[ "${quest_object_here}" == true ]]; then
                add_item_handler "${in_progress_random_dungeon[rescue_name],,}"
                in_progress_random_dungeon[rescue_location]=""
                in_progress_random_dungeon[rescue_state]=true
                clear
                update_room_after_take
            fi
            return
        ;;         
        *)
            if [[ -z "${noun}" ]]; then #if player just types take
                desc_room
                echo
                echo "You take a deep breath, taking it all in.."
            fi
        ;;

    esac

    case $noun:$location in

        *sword*:"fandor_gh_outside")
            noun="short sword"
            if [[ "${story_loot[guild_hall_short_sword]}" == true ]];then
                add_item_handler "$noun"
                story_loot[guild_hall_short_sword]=false
                update_room_after_take
            else
                nothing_to_take
            fi
        ;;
        *)
            if [[ -n "${noun}" ]]; then #if its an unknown noun
                desc_room
                echo
                echo -e "${ITALIC}You don't see $noun${RESET}"
            fi

    esac      
}

#-------------------------
#USE VERB HANDLER
#-------------------------

use_handler() {

    case $noun in

        *)
            if [[ -z "${noun}" ]]; then #if player just types use
                read -r -p "Use what? > " noun
                noun="${noun,,}"
            fi
        ;;

    esac

    case $noun:$location in

        *board*:"guild_hall_center")
            state="using_quest_board"
        ;;
        *clerk*:"guild_hall_center")
            verb="talk"
            noun="clerk"
            talk_handler
        ;;
        *trophy*:"fandor_gh_bar")
            state="trophy_board"
        ;;
        *board*:"fandor_gh_bar")
            state="trophy_board"
        ;;
        *dummy*:"fandor_gh_outside")
            combat_rank="Z"
            state="combat"
        ;;
        *portal*:"fandor_gh_outside")
            state="portal_entrance"
        ;;  

        *)
            if [[ -n "${noun}" ]]; then #if its an unknown noun
                desc_room
                echo
                echo -e "${ITALIC}You can't use $noun${RESET}"
            fi
        ;;
    esac      
}

#-------------------------
#Name confirm
#-------------------------

name_confirm() {
            read -r -p "Name: " input_name
            [[ -z "${input_name}" ]] && name_confirm
            echo "You wrote $input_name, is that right?"
            read -r -p "Yes or No: " confirm_name
            confirm_name="${confirm_name,,}"

            
            [[ "${confirm_name}" == "y"* ]] && name=$input_name && stored_chat_update
            [[ "${confirm_name}" == "n"* ]] && name_confirm
            
            }

#-------------------------
#class confirm
#-------------------------

class_confirm() {
            read -r -p "Class: " input_class
            [[ -z "${input_class}" ]] && class_confirm
            input_class="${input_class,,}"
            case $input_class in
                w|warrior) input_class="warrior";;
                c|cleric) input_class="cleric";;
                m|mage) input_class="mage";;
                p|paladin) input_class="paladin";;
                *) echo "Choose a class from the list please" && class_confirm
            esac

            echo "You chose $input_class, is that right?"
            read -r -p "Yes or No: " confirm_class
            confirm_class="${confirm_class,,}"

            
            [[ "${confirm_class}" == "y"* ]] && class=$input_class && stored_chat_update
            [[ "${confirm_class}" == "n"* ]] && class_confirm
            
            }   

#-------------------------
#race confirm
#-------------------------

race_confirm() {
            read -r -p "Race: " input_race
            [[ -z "${input_race}" ]] && race_confirm
            input_race="${input_race,,}"
            case $input_race in
                hf|halfling) input_race="halfling" ;;
                h|human) input_race="human" ;;
                e|elf) input_race="elf" ;;
                d|dwarf) input_race="dwarf" ;;
                o|orc) input_race="orc" ;;
                *) echo "Choose a race from the list please" && race_confirm
            esac

            echo "You chose $input_race, is that right?"
            read -r -p "Yes or No: " confirm_race
            confirm_race="${confirm_race,,}"

            
            [[ "${confirm_race}" == "y"* ]] && race=$input_race && stored_chat_update
            [[ "${confirm_race}" == "n"* ]] && race_confirm
            
            } 
         
character_creation_handler() {

if [[ "${char_creation_done}" == false ]]; then
    echo
    echo "Write your name down"
    echo
    name_confirm
    clear
    echo -e "${fandor_guild[clerk_class]}" 
    echo
    class_confirm
    clear
    echo -e "${fandor_guild[clerk_race]}"
    echo
    race_confirm
    clear
    echo -e "${tutorial[character_screen]}"
    press_any_to_continue
    prev_state="chat"
    char_creation_done=true
    state="char_screen"
    location="guild_hall_center"
fi

}

#-------------------------
#TALK VERB HANDLER
#-------------------------

talk_handler() {
    
    case $noun in

        *)
            if [[ -z "${noun}" ]]; then #if player just types look
                echo "Talking to yourself again?"
            fi
        ;;

    esac
    if [[ "${char_creation_done}" == false ]]; then
        case $noun:$location in

            "clerk":"room_reg_tutorial")
                location="room_tutorial_end"
                desc_room
            ;;

            "clerk":"room_tutorial_end")
                who="clerk"          
                state="chat"
                clear
                echo -e "${fandor_guild[clerk_introduction]}"
            ;;

            *)
                if [[ -n "${noun}" ]]; then #if its an unknown noun
                    desc_room
                    echo "$noun doesn't want to talk to you"
                fi

        esac      
    fi
    if [[ "${char_creation_done}" == "finished" ]]; then

        case $noun in
        barkeep) noun="bartender" ;;
        durgin) noun="bartender" ;;
        esac

        case $noun:$location in

        "clerk":"guild_hall_center")
            who="clerk"
            state="chat"
            clear ; stored_chat_update
            echo -e "${fandor_guild[clerk_default_1]}"
            waiting_chat
            wait
            echo -e "${fandor_guild[clerk_default_2]}"
        ;;

        "bartender":"fandor_gh_bar")
            who="durgin"
            state="chat"
            if (( chat_states[fandor_bartender] == 0 ));then
                echo -e "${fandor_guild[bartender_firstmeeting]}"
                chat_states[fandor_bartender]=1
            else
                echo -e "${fandor_guild[bartender_default]}"
            fi
        ;;
        "bar":"fandor_gh_bar")
            desc_newline
            echo -e "${talk_object[bar]}"
        ;;

        "dummy":"fandor_gh_outside")
            who="dummy"
            state="chat"
            clear ; stored_chat_update
            dummy_chat
        ;;           
        *)
            if [[ -n "${noun}" ]]; then #if its an unknown noun
                desc_room
                echo "$noun doesn't want to talk to you"
            fi

        esac
    fi     
}
#-------------------------
#COLLECT HANDLER
#-------------------------
    collect_handler(){
        if [[ "${in_progress_random_dungeon[state]}" == "complete" ]];then

            case "${in_progress_random_dungeon[type]}" in
            "CLEAR ALL MONSTERS")
                echo -e "${fandor_guild[clerk_collect_success_neutral]}"
            ;;
            "COLLECT")
                echo -e "${fandor_guild[clerk_collect_success_materials]}"
            ;;
            "RESCUE")
                echo -e "${fandor_guild[clerk_collect_success_rescue]}"
            ;;
            esac

            combat_rank_lower_cased="${in_progress_random_dungeon[rank],,}"

            gold_reward="${combat_rank_lower_cased}_rank_quest_gold"
            xp_reward="${combat_rank_lower_cased}_rank_quest_xp"
            
            echo
            echo -e "A pouch containing ${YELLOW}${quest_rewards[$gold_reward]} gold coins.${RESET}"
            echo -e "You feel more experienced. ${MAGENTA}${quest_rewards[$xp_reward]} experience gained.${RESET}"

            (( player_gold += quest_rewards[$gold_reward] ))
            (( player_xp += quest_rewards[$xp_reward] ))

            # clean up {------------------
            for item in "${!player_inventory[@]}";do
                local type="${item_type[$item]}"
                [[ "${type}" == "minor_quest_item" ]] && unset "player_inventory[$item]"
            done
            local rescue_person="${in_progress_random_dungeon[rescue_name],,}"
            rescue_person="${rescue_person// /_}"
            [[ "${in_progress_random_dungeon[type]}" == "RESCUE" ]] && unset "item_type[$rescue_person]" && unset "minor_quest_item_data[${rescue_person}_description]" 
            in_progress_random_dungeon=()
            in_progress_random_dungeon[state]=false
            # -----------------}

        else
            echo -e "${fandor_guild[clerk_collect_failure_neutral]}"
        fi
    }

#-------------------------
#CHAT HANDLER
#-------------------------

chat_handler() {

    case $noun in
        *bye*|goodbye|gb)
            who=""
            state="nav"
        ;;

    esac
    #### before character is created
    if [[ "${char_creation_done}" == false ]]; then

        case $verb in
            *bother*) verb="yes";;
            *annoy*) verb="yes";;
            *reg*) verb="reg" ;;
            "register") verb="reg" ;;
            "registration") verb="reg" ;;

        esac

        case $verb:$who in
           "yes":"clerk")
                echo -e "Of course you are. \nShe dips a quill in ink, and hands it to you with a document."
                character_creation_handler
            ;;
            "reg"*:"clerk")
                echo "She dips a quill in ink, and hands it to you with a document."
                character_creation_handler
            ;;
            "collect"*:"clerk")
                echo -e "${fandor_guild[clerk_collection]}"
                echo "She dips a quill in ink, and hands it to you with a document."
                character_creation_handler           
            ;;
            *:"clerk")
            echo "You're not from around here are you?"
            echo
            echo -e "${fandor_guild[clerk_introduction]}"
            ;;

            *)
                if [[ -n "${noun}" ]]; then #if its an unknown noun
                    echo "$who doesn't know WHAT you are talking about!"
                fi

        esac 

        return     
    fi
#### normal after creation

case $verb in
"collection") verb="collect";;
"turn") verb="collect";;
"finished") verb="collect";;
"complete") verb="collect";;
"gb") verb="goodbye" ;;
"purchase") verb="buy";;
"shop") verb="buy";;
"store") verb="buy";;
"wares") verb="buy";;
"goods") verb="buy";;
"browse") verb="buy";;
"trade") verb="buy";;
"barter") verb="buy";;
"merchant") verb="buy";;
"supplies") verb="buy";;
"equipment") verb="buy";;
"stock") verb="buy";;
"inventory") verb="buy";;
"purchase") verb="buy";;
"buying") verb="buy";;
"see") verb="buy";;
"show") verb="buy";;
"look") verb="buy";;
"items") verb="buy";;
"drink") verb="buy";;
"ale") verb="buy";;
"brew") verb="buy";;
"stout") verb="buy";;

esac

case $verb:$who in


    *collect*:"clerk")
    collect_handler
    ;;

    *:"clerk")
    echo "You're not from around here are you?"
    echo
    echo -e "${fandor_guild[clerk_default_2]}"
    ;;

    *:"dummy")
    dummy_chat
    ;;

    "buy":durgin)
        prev_location="${location}"
        vendor="fandor_bartender"
        state="shopping"
    ;;

    "information":"durgin"|"info":"durgin")
        echo -e "${fandor_guild[bartender_info_$(( RANDOM % 10 ))]}"
    ;;

    *:"durgin")
        echo -e "${fandor_guild[bartender_default]}"
    ;;

    *)
        if [[ -n "${noun}" ]]; then #if its an unknown noun
            echo "$who doesn't know WHAT you are talking about!"
        fi

esac          

}

    action1="placeholder1"
    action2="placeholder2"


#-------------------------
#IS ENEMY DEAD HANDLERS
#-------------------------
completed_quest_checker(){
    case "${in_progress_random_dungeon[type]}" in
    "CLEAR ALL MONSTERS")
        if (( "${in_progress_random_dungeon[enemies_killed]}" >= "${in_progress_random_dungeon[total_enemies]}" ));then
            in_progress_random_dungeon[state]="complete"
        fi
    ;;
    "COLLECT")
        if (( "${in_progress_random_dungeon[material_collected]}" >= "${in_progress_random_dungeon[material_amount]}" ));then
            in_progress_random_dungeon[state]="complete"
        fi
    ;;
    "RESCUE")
        if [[ "${in_progress_random_dungeon[rescue_state]}" == true ]];then
            in_progress_random_dungeon[state]="complete"
        fi
    ;;
    esac

    # if [[ "${in_progress_random_dungeon[type]}" == "CLEAR ALL MONSTERS" ]];then
    #     if (( "${in_progress_random_dungeon[enemies_killed]}" >= "${in_progress_random_dungeon[total_enemies]}" ));then
    #         in_progress_random_dungeon[state]="complete"
    #     fi    
    # if [[ "${in_progress_random_dungeon[type]}" == "COLLECT" ]];then
    #     if (( "${in_progress_random_dungeon[material_collected]}" >= "${in_progress_random_dungeon[material_amount]}" ));then
    #         in_progress_random_dungeon[state]="complete"
    #     fi
    # else
    #     if [[ "${in_progress_random_dungeon[rescue_state]}" == true ]];then
    #         in_progress_random_dungeon[state]="complete"
    #     fi
    # fi
}
quest_completed_text(){
    if [[ "${in_progress_random_dungeon[state]}" == "complete" ]];then
        echo -e "\n\n${BG_BLACK}${BLINK}${BRIGHT_WHITE}QUEST COMPLETE${RESET} - TURN INTO A CLERK AT AN ADVENTURES GUILD."
    fi
}

death_handler(){
    enemy_dead=false
    if (( ehp <= 0 ));then
        enemy_dead_screen
        press_any_to_continue
        (( enemies_killed_stat++ ))
        (( enemy_kills[$ename]++ ))
        [[ "${in_progress_random_dungeon[type]}" == "CLEAR ALL MONSTERS" ]] && (( in_progress_random_dungeon[enemies_killed]++ ))
        state="nav"
        start_combat=true
        flee_success=true
        completed_quest_checker
        enemy_dead=true
    fi
}

#-------------------------
#FLEE HANDLER
#-------------------------

flee_handler() {
player_number=$(( RANDOM % 4 + 1 ))
winning_number=$(( RANDOM % 4 + 1 ))

if (( $player_number == $winning_number )); then
clear
local rand=$(( RANDOM % ${#flee[@]} ))
echo -e "${flee[$rand]}"
echo -e "\n\n"
read -r -p 'PRESS ENTER TO CONTINUE'
combat_rank="$base_rank" 
state="nav"
start_combat=true
flee_success=true
else
    action1="You could not get away!"
    player_health=$(( player_health - eattack ))
    action2="$ename hits you for $eattack"

fi

}

#-------------------------
# A OR AN VOWEL CHECKER
#-------------------------

a_an_checker() {
if [[ "${ename:0:1}" =~ [AEIOUaeiou] ]];then
aan="an"
else
aan="a"
fi
}

#-------------------------
#SKILLS HANDLER
#-------------------------

skills_handler(){
found=false

for (( i=0; i<${#player_skills[@]}; i++ ));do
            lower_case_skills="${player_skills[i],,}"
            if [[ "${action}" == "${lower_case_skills}" ]]; then
                declare -n skills_ref="${lower_case_skills// /_}"
                skill_damage=$(( ${skills_ref[damage]} ))
                skill_cost=$(( ${skills_ref[skill_consumption]} ))
                    if (( ${player_skill_points} - ${skill_cost} > -1 )); then
                        player_skill_points=$(( ${player_skill_points} - ${skill_cost} ))
                        ehp=$((ehp - skill_damage))
                        death_handler ; [[ "${enemy_dead}" == true ]] && return                        
                        action1="You cast $lower_case_skills on the $ename for $skill_damage pts! It cost you $skill_cost skill points."
                        player_health=$(( player_health - eattack ))
                        action2="$ename hits you for $eattack pts."
                        found=true
                    else
                        action1="Not enough skill points"
                        action2="$ename looks impatient"
                    fi
                break
            fi  
            
    done

if [[ "${found}" == false ]]; then
    echo "no match found"
fi
}

#-------------------------
#SPELL HANDLER
#-------------------------

spell_handler(){
found=false

for (( i=0; i<${#player_spells[@]}; i++ ));do
            lower_case_spell="${player_spells[i],,}"
            if [[ "${action}" == "${lower_case_spell}" ]]; then
                declare -n spell_ref="${lower_case_spell// /_}"
                magic_damage=$(( ${spell_ref[damage]} ))
                mana_cost=$(( ${spell_ref[mana_consumption]} ))
                    if (( ${player_mana} - ${mana_cost} > -1 )); then
                        player_mana=$(( ${player_mana} - ${mana_cost} ))
                        ehp=$((ehp - magic_damage))
                        death_handler ; [[ "${enemy_dead}" == true ]] && return
                        action1="You cast $lower_case_spell on the $ename for $magic_damage pts! It cost you $mana_cost mana."
                        player_health=$(( player_health - eattack ))
                        action2="$ename hits you for $eattack pts."
                        found=true
                    else
                        action1="Not enough mana"
                        action2="$ename looks impatient"
                    fi
                break
            fi  
            
    done

if [[ "${found}" == false ]]; then
    echo "no match found"
fi
}

#-------------------------
#DESCRIBE ENEMY (ALSO SET DAMAGE? NOT SURE WHY I PUT THAT HERE)
#-------------------------

set_enemy_attack() {

    case $combat_rank in
        #EATTACK_RANGES
        Z)
        eattack=0
        ;;

        F)
        eattack=$(( RANDOM % ( f_max_damage - f_min_damage + 1 ) + f_min_damage ))
        ;;

        E)
        eattack=$(( RANDOM % ( e_max_damage - e_min_damage + 1 ) + e_min_damage ))
        ;;

    esac 
}

enemy_display() {
        echo "$ename     Health: $ehp"     
        #echo "EATTACK_DEBUG: $eattack"
        echo
        echo
}
        

#-------------------------
#COMBAT TEXT USER INTERFACE
#-------------------------

combat_menu="attack"
cast_spell=""
comb_tui() {

    case $combat_menu in

        attack) 
            echo "$action1"
            echo "$action2"
            echo
            echo
            echo "$name     Health: $player_health     Mana: $player_mana   Skill Points: $player_skill_points"
            echo
            echo "A)ttack"
            echo "M)agic"
            echo "S)kills"
            echo "D)efend"
            echo "F)lee"
            echo "H)elp"
        ;;

        magic) 
            echo "$action1 $cast_spell"
            echo "$action2"
            echo
            echo
            echo "$name     Health: $player_health     Mana: $player_mana   Skill Points: $player_skill_points"
            echo
            printf "Spells: "
            printf "%s ░ " "${player_spells[@]}"
            echo
            echo "B)ack"
        ;;

        skills) 
            echo "$action1"
            echo "$action2"
            echo
            echo
            echo "$name     Health: $player_health     Mana: $player_mana   Skill Points: $player_skill_points"
            echo
            printf "Skills: "
            printf "%s ░ " "${player_skills[@]}"
            echo
            echo "B)ack"
#            echo "PA DEBUG: $player_attack"

        ;;

        help)
            echo "Combat tutorial:"
            echo
            echo "Enter commands via the prompt that correspond to the desired action."
            echo "Example: to attack, either input \"a\" or \"attack\". Finalize the action by pressing return."
            echo
            echo "A)ttack: A melee attack using the currently equipped weapon."
            echo
            echo "S)kills: Use acquired player skills, costing skill points in the process. After entering the skills menu, enter the full skill name and press return to use it. Only available skills will be listed."
            echo
            echo "M)agic: Use acquired player spells, costing mana in the process. After entering the spell menu, enter the full spell name and press return to cast. Only available spells will be listed."
            echo
            echo "D)efend: Spend the turn defending against enemy damage and recovering mana. Defense and mana recovery are based on player stats."
            echo
            echo "F)lee: Attempt to escape the current fight and return to the beginning of the instance. Failing to flee will result in the enemy attacking you without fail."
            echo
            echo "B)ack: Return to the previous menu."
            echo
        ;;

    esac
}

melee_attack_handler() {
    local attackdamage=$(( RANDOM % 3 + 0 + $player_attack ))
    ehp=$((ehp - attackdamage))
    death_handler ; [[ "${enemy_dead}" == true ]] && return
    action1="You hit the $ename for $attackdamage pts!"
    player_health=$(( player_health - eattack ))
    action2="$ename hits you for $eattack"
}
#-------------------------
#COMBAT HANDLER
#-------------------------

combat_handler() {

#-------------------------
# - ATTACK/MAIN STATE    
#-------------------------

    if [[ "${combat_menu}" == "attack" ]]; then

        case "$action" in
            a|attack)
                melee_attack_handler
            ;;

            s|skills)
                combat_menu="skills"
            ;;
            m|magic)
                combat_menu="magic"
            ;;

            f|flee)
                flee_handler
            ;;

            d|defend)
                defend_handler
            ;;

            h|help)
                combat_menu="help"
            ;;

        esac
    fi
#-------------------------
# - MAGIC STATE
#-------------------------

    if [[ "${combat_menu}" == "magic" ]]; then

    spell_handler

        case "$action" in
            b|back)
                combat_menu="attack"
            ;;
        esac

    fi
#-------------------------
# - SKILL STATE
#-------------------------

    if [[ "${combat_menu}" == "skills" ]]; then

    skills_handler

        case "$action" in
            b|back)
                combat_menu="attack"
            ;;
        esac

    fi

#-------------------------
# - HELP STATE
#-------------------------

    if [[ "${combat_menu}" == "help" ]]; then

        case "$action" in
            b|back)
                combat_menu="attack"
            ;;
        esac

    fi


}