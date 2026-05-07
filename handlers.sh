#!/usr/bin/env bash

#-------------------------
#DESCRIBE ROOM
#-------------------------

desc_room() {
    [[ ${in_random_dungeon} == false ]] && echo -e "${room_desc[$location]}"
    [[ ${in_random_dungeon} == true ]] && theme_banner="${banner_title//_/ }" && theme_banner="${theme_banner^^}" && echo -e "\e[7m${theme_banner}\e[0m\n"
    [[ ${in_random_dungeon} == true ]] && echo "${random_dungeon_properties["$location,description"]}"
 
    if [[ ${in_random_dungeon} == true ]]; then
        random_dungeon_spawner
        obv_exits=()
        obv_exit_checker_north
        obv_exit_checker_south
        obv_exit_checker_east
        obv_exit_checker_west
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
        flee_success=false
    fi
}

desc_newline(){
    desc_room
    echo  
}

hurt_player(){
    local lose=$1
    (( player_health - lose > 0 )) && (( player_health -= lose ))
    (( player_health - lose <= 0 )) && state="dead"
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

    case $noun:$location in

    *clerk*:"guild_hall_center")
            clerk_lick
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
    (( player_mana + mana_add <= max_mana )) && (( player_mana += mana_add ))
    (( player_mana + mana_add > max_mana )) && player_mana=$max_mana
}
recover_health() {
    local health_add=$1
    (( player_health + health_add <= max_health )) && (( player_health += health_add ))
    (( player_health + health_add > max_health )) && player_health=$max_health
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
                [[ $valid = false ]] && echo "You can't go that way"
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
                [[ $valid = false ]] && echo "You can't go that way"
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
                [[ $valid = false ]] && echo "You can't go that way"
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
                [[ $valid = false ]] && echo "You can't go that way"
}

#-------------------------
#RANDOM DUNGEON OBVIOUS EXITS
#-------------------------

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
                        break
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
                        break       
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
                        break       
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
                        break
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
                #echo "location: $location"
                desc_room
                #draw_dungeon
                                
            ;;

            "south")
                rdung_nav_checker_south
                #echo "location: $location"
                desc_room
                #draw_dungeon
                
            ;;

            "west")
                rdung_nav_checker_west
                #echo "location: $location"
                desc_room
                #draw_dungeon
                
            ;;

            "east")
                rdung_nav_checker_east
                #echo "location: $location"
                desc_room
                #draw_dungeon
                
            ;;

            *)
                echo "You can't go that way"
            ;;

        esac
        
        [[ ${draw_dungeon} == true ]] && echo && draw_dungeon 
    fi

    story_navigation

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
        *door*:"guild_hall_center")
            echo "${object_look[fandor_gh_door]}"
        ;;
        "west":"guild_hall_center")
            echo "${object_look[fandor_gh_bar]}"
        ;;
        *bar*:"guild_hall_center")
            echo "${object_look[fandor_gh_bar]}"
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

take_handler() {

    case $noun in

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
                read -r -p "Use what? " noun
                noun="${noun,,}"
            fi
        ;;

    esac

    case $noun:$location in

        *board*:"guild_hall_center")
            echo "YOU USE THE BOARD"
        ;;
        *dummy*:"fandor_gh_outside")
            combat_rank="Z"
            state="combat"
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
        case $noun:$location in

        "clerk":"guild_hall_center")
            who="clerk"
            state="chat"
            clear
            echo -e "${fandor_guild[clerk_default]}"
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
#CHAT HANDLER
#-------------------------

chat_handler() {

    case $noun in
        *bye*|goodbye)
            who=""
            state="nav"
        ;;

    esac
    #### before character is created
    if [[ "${char_creation_done}" == false ]]; then
        case $verb:$who in


            "yes":"clerk")
                echo "Of course you are. She hands you a document, dips a quill in ink and hands it you."
                character_creation_handler
            ;;

            "reg"*:"clerk")
                echo "She hands you a document, dips a quill in ink and hands it you."
                character_creation_handler
            ;;

            "collect"*:"clerk")
                echo -e "${fandor_guild[clerk_collection]}"
                echo "She hands you a document, dips a quill in ink and hands it you."
                character_creation_handler           
            ;;

            *:"clerk")
            echo "You're not from around here are you?"
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
case $verb:$who in


    "yes":"clerk")
        echo "this is all i know right now."
    ;;

    *:"clerk")
    echo "You're not from around here are you?"
    echo -e "${fandor_guild[clerk_default]}"
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
#FLEE HANDLER
#-------------------------

flee_handler() {
player_number=$(( RANDOM % 4 + 1 ))
winning_number=$(( RANDOM % 4 + 1 ))

if (( $player_number == $winning_number )); then
clear
rand=$(( RANDOM % ${#flee[@]} ))
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
        eattack=$(( RANDOM % 10 + 1 ))
        ;;

        E)
        eattack=$(( RANDOM % 20 + 1 ))
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