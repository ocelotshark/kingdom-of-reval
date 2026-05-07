#!/usr/bin/env bash

declare -gA player_equipment=(
    [weapon]=""
    [armor]=""
    [accessory]=""
)

declare -gA player_inventory=(
    [cloth_tunic]=1
    [necklace_of_life]=1
    [necklace_of_mana]=1
    [apple]=2
)

add_item_handler() {
    local add_item="$1"
    add_item="${add_item// /_}"
    (( player_inventory["$add_item"]++ ))
}

view_inventory() {
        desc_room
        echo

        local count=0

        for key in "${!player_inventory[@]}"; do
        local value="${player_inventory[$key]}"
        local display_key="${key//_/ }"
        display_key="${display_key^}"
        printf '%b  ' "${ITALIC}${display_key} x $value${RESET}"

        ((count++))

        (( count % 4 == 0 )) && printf '\n'

    done
        (( count % 4 != 0 )) && printf '\n'
}

view_equipment() {
        desc_room
        echo

        local count=0

        for key in "${!player_equipment[@]}"; do
        local value="${player_equipment[$key]}" 
        local display_key="${key//_/ }"
        display_key="${display_key^}"
        local display_value="${value//_/ }"
        display_value="${display_value^}"
        printf '%b  ' "${REVERSE}${display_key} >> $display_value${RESET}"

        ((count++))

        (( count % 4 == 0 )) && printf '\n'

    done
        (( count % 4 != 0 )) && printf '\n'
}

remove_item_handler () {
    local remove_item="$1"
    remove_item="${remove_item// /_}"
    if (( player_inventory["$remove_item"] == 0 )); then
    echo "You don't have that"
    elif (( player_inventory["$remove_item"] == 1 )); then
    unset player_inventory["$remove_item"]
    else
    (( player_inventory["$remove_item"]-- ))
    fi
}

use_equipment() {
    local check_item="$1"
    local type="$2"

    if [[ "${check_item}" == "${player_equipment[$type]}" ]];then
        desc_newline                
        echo "That's already equipped!"
        return
    fi

    if [[ -v player_inventory["$check_item"] ]];then
        if [[ -n "${player_equipment[$type]}" ]];then
            local remove_equipped="${player_equipment[$type]}"
            accessory_remove_stats
            add_item_handler $remove_equipped
            player_equipment[$type]="$check_item"
            accessory_add_stats
            remove_item_handler "$check_item"
            desc_newline
            echo -e "Swapped ${remove_equipped//_/ } with ${check_item//_/ }"
        else
            player_equipment[$type]="$check_item"
            remove_item_handler "$check_item"
            accessory_add_stats
            desc_newline
            echo -e "Equipped ${check_item//_/ } to $type"
        fi
    else
        desc_newline
        echo "You don't have that"
    fi
    stat_modifi_handler

}

remove_equipped_item(){
    local removing_item="$1"
    removing_item="${removing_item// /_}"

    [[ -v item_type["$removing_item"] ]] && local type="${item_type["$removing_item"]}"
    
        if [[ "${player_equipment[$type]}" == "$removing_item" ]];then
            add_item_handler "$removing_item"
            accessory_remove_stats
            player_equipment[$type]=""
            desc_newline
            echo -e "Removed ${removing_item//_/ }"
        else
            desc_newline
            echo "That isn't equipped"
        fi
    [[  -z "${player_equipment[weapon]}" ]] && echo ; echo "You are unarmed"
    [[  -z "${player_equipment[armor]}" ]] && echo ; echo "You are naked..."
    stat_modifi_handler
}

use_consumable(){
    local consume="$1"
    if [[ -v player_inventory[$consume] ]];then
        local modify_var="${consumable_data[${consume}_modify_variable]}"
        local modify_val="${consumable_data[${consume}_modify_value]}"
        local -n stat="$modify_var"

        remove_item_handler "$consume"
        
        case $stat in
            "${player_health}")
            recover_health $modify_val
            desc_room
            echo
            echo "Consuming the $consume you heal for $modify_val points!"
            stat_modifi_handler
            echo "Your health is $player_health/$max_health"
            ;;
        esac

    else
        desc_room
        echo    
        echo "You need the $consume to do that!"
    fi

}

look_parsing_handler(){
    local noun="$1"
    noun="${noun// /_}"
    if [[ -v player_inventory[$noun] ]];then
        local type="${item_type[${noun}]}"
        local -n type_ref="${type}_data"
        local description="${type_ref[${noun}_description]}"
            [[ "${type}" == "weapon" ]] && local damage="Damage: ${weapon_data[${noun}_damage]}    Value: ${weapon_data[${noun}_value]}"
            [[ "${type}" == "armor" ]] && local defense="Defense: ${armor_data[${noun}_defense]}    Value: ${armor_data[${noun}_value]}"
            [[ "${type}" == "accessory" ]] && local accessory_effects="${accessory_data[${noun}_effects]}   Value: ${accessory_data[${noun}_value]}"
        desc_room
        echo
        local display_noun="${noun//_/ }"
        display_noun="${display_noun^}"
        echo -e "${ITALIC}You examine the $display_noun${RESET}"
        echo "$description"
        printf "$damage"
        printf "$defense"
        printf "$accessory_effects"
        printf "\n"
    else
        noun="${noun//_/ }"
        look_handler
    fi
}

parse_item_type() {
    local item="$1"
    item="${item// /_}"

    if [[ -v item_type["$item"] ]];then
        local type="${item_type["$item"]}"
        case $type in
            weapon)
            use_equipment "$item" "$type"
            ;;
            armor)
            use_equipment "$item" "$type"
            ;;
            consumable)
            use_consumable "$item"
            ;;
            accessory)
            use_equipment "$item" "$type"
            ;;
            object)
            :
            ;;
        esac
    else
        noun="${noun//_/ }"
        use_handler
    fi
    
}
