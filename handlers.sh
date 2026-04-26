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
#-------------------------
#DEFEND
#-------------------------

defend_handler() {
defend_weight=$(( RANDOM % $player_defense + 2 ))
defended_damage=$(( eattack / defend_weight ))
defended_against=$(( eattack - defended_damage ))
action1="You defended against $defended_against pts! Focusing you recover $mana_recovery pts of mana!"
action2="$ename hits you for $defended_damage"
player_health=$(( player_health - defended_damage ))
player_mana=$(( player_mana + mana_recovery ))
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

        "pool":"room1")
            desc_room
            echo "The water is disgusting"
        ;;

        *)
            if [[ -n "${noun}" ]]; then #if its an unknown noun
                desc_room
                echo "You don't see $noun"
            fi

    esac      
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
}

#-------------------------
#CHAT HANDLER
#-------------------------

chat_handler() {

    case $noun in
        *bye*)
            echo "goodbye"
        ;;

    esac

    case $verb:$who in

        "yes":"clerk")
            echo "name please"
        ;;

        "registration":*)
            echo "name please"
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
            echo "PA DEBUG: $player_attack"

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