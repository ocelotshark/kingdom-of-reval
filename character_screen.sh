#!/usr/bin/env bash

weapon_damage_pull(){
    if [[ -n "${player_equipment[weapon]}" ]];then
        local weapon="${player_equipment[weapon]}"
        weapon_damage="${weapon_data[${weapon}_damage]}"
    else
        weapon_damage=1
    fi
}

armor_defense_pull(){
    if [[ -n "${player_equipment[armor]}" ]];then
        local armor="${player_equipment[armor]}"
        armor_defense="${armor_data[${armor}_defense]}"
    else
        armor_defense=0
    fi
}

accessory_add_stats(){
    if [[ -n "${player_equipment[accessory]}" ]];then
        local accessory="${player_equipment[accessory]}"
        local modify_var="${accessory_data[${accessory}_modify_variable]}"
        local modify_value="${accessory_data[${accessory}_modify_value]}"
        local -n stat="${modify_var}"

        (( stat += modify_value ))
    fi
}

accessory_remove_stats(){
    if [[ -n "${player_equipment[accessory]}" ]];then
        local accessory="${player_equipment[accessory]}"
        local modify_var="${accessory_data[${accessory}_modify_variable]}"
        local modify_value="${accessory_data[${accessory}_modify_value]}"
        local -n stat="${modify_var}"

        (( stat -= modify_value ))
    fi
}

stat_modifi_handler() {

determination_modifi=$(( determination / 10 ))
intelligence_modifi=$(( intelligence * 3 ))
strength_modifi=$(( strength / 3 ))

[[ "${class}" == "warrior" ]] && warrior_modifi=$(( lvl * 1 ))
[[ "${class}" == "cleric" ]] && cleric_modifi=$(( lvl * 10 ))
[[ "${class}" == "mage" ]] && mage_modifi=$(( lvl * 5 ))
[[ "${class}" == "paladin" ]] && paladin_modifi=$(( lvl / 5 ))
next_level=$(( lvl + 1 ))

health_modifi=$(( lvl * 10 ))

max_mana=$(( base_max_mana + intelligence_modifi + mage_modifi + bonus_mana ))
max_health=$(( base_max_health + health_modifi + cleric_modifi + bonus_health ))
weapon_damage_pull
player_attack=$(( base_attack + strength_modifi + warrior_modifi + weapon_damage))
max_skill_points=$(( determination_modifi + paladin_modifi ))
armor_defense_pull
player_defense=$(( base_defense + armor_defense ))
}

reputation_to_string() {

    if (( player_reputation >= 90 )); then
        str_player_reputation="Legendary Hero"

    elif (( player_reputation >= 80 )); then
        str_player_reputation="Renowned Hero"

    elif (( player_reputation >= 70 )); then
        str_player_reputation="Proven Hero"

    elif (( player_reputation >= 60 )); then
        str_player_reputation="Trusted Adventurer"

    elif (( player_reputation >= 50 )); then
        str_player_reputation="Neutral"

    elif (( player_reputation >= 40 )); then
        str_player_reputation="Unpredictable"

    elif (( player_reputation >= 30 )); then
        str_player_reputation="Shady"

    elif (( player_reputation >= 20 )); then
        str_player_reputation="Notorious"

    elif (( player_reputation >= 10 )); then
        str_player_reputation="Dangerous"

    else
        str_player_reputation="Infamous Villain"
    fi

}

press_any_to_continue() {
        read -rsn1 -p "Press any key to continue..."
        echo
}

allocate_points_handler() {
declare -n selected_stat=$1
read -r -p "Points to allocate: " addpoints
    if [[ $addpoints =~ ^[0-9]+$ ]];then
        if (( addpoints - lvl_points <= 0 )); then
            selected_stat=$(( selected_stat + addpoints ))
            lvl_points=$(( lvl_points - addpoints ))
                if (( addpoints > 0 )); then
                            char_input=""
                            stat_modifi_handler
                fi
        else
            echo "You don't have enough points for that!"
            press_any_to_continue
        fi
    else
        echo "That's not a number."
        press_any_to_continue
    fi

}

update_player_stats() {
    stat_modifi_handler
    reputation_to_string
}


char_screen_tui() {

update_player_stats
clear

echo -e "${REVERSE} $name    Level:$lvl    Rank:${player_rank^^} ${RESET}"
echo
echo " Health: $player_health/$max_health"
echo " Mana: $player_mana/$max_mana"
echo " Mana Recovery: $mana_recovery"
echo " Skill Points: $player_skill_points/$max_skill_points"
echo " $name's Maximum Attack Power: $player_attack"
echo " Defense: $player_defense"
echo " Class: ${class^^}    Race: ${race^^}"
echo
echo " Determination: $determination"
echo " Strength: $strength"
echo " Intelligence: $intelligence"
echo
echo -e " Reputation:${REVERSE} $str_player_reputation ${RESET}"
echo
printf " Active Effects: "
(( ${#player_uffs} == 0 )) && printf "None"
(( ${#player_uffs} != 0 )) && printf "%s, " "${player_uffs[@]}"
echo
echo
echo " Stat Points Unallocated: $lvl_points"
echo
echo " Allocate Points to: "
echo " D)etermination"
echo " S)trength"
echo " I)ntelligence"
echo
echo " B)ack"
echo
echo -e "${REVERSE} XP TO LVL $next_level - $player_xp/$xp_to_next_lvl ${RESET}" 
echo
read -r -p "> " char_input
char_input="${char_input,,}"

case $char_input in
    d|determination)
        allocate_points_handler determination
    ;;
    s|strength)
        allocate_points_handler strength
    ;;
    i|intelligence)
        allocate_points_handler intelligence
        char_input=""
    ;;
    b|back)
        [[ "${char_creation_done}" == false ]] && char_creation_done=true 
        clear
        flee_success=true
        state="${prev_state}"
    ;;

esac

}
