#!/usr/bin/env bash

mapfile -t rescue_desc_array < rescue_npc_desc.txt
e_spawn_chance=5
f_spawn_chance=5
max_enemies=100

max_enemies_max_min () {
    local max_enemies_pop=$1
    local min_enemies_pop=$2
    local -n total_enemies="$3"

    (( min_enemies_pop > max_enemies_pop )) && echo "min ($min_enemies_pop) cannot be greater than max ($max_enemies_pop) IDIOT" && return 1

    total_enemies=$(( RANDOM % (max_enemies_pop - min_enemies_pop + 1) + min_enemies_pop ))
}

declare -A random_dungeon_properties

#-------------------------
#VARIABLES THAT random_dungeon_init() RELIES ON
#-------------------------
dungeon_gen() {
location_tmp="$location"
rooms=()
wod=$1
hod=$2
bl=0
bt=0
br=$wod
bb=$hod
max_rooms=$(( wod + hod ))
random_c=$(( RANDOM % br ))
random_r=$(( RANDOM % bb ))
room_zero="$random_r,$random_c"
rooms+=("${room_zero}")
r=$random_r
c=$random_c
room_candidate=()
birth_chance=3

[[ ! -z "$3" ]] && local themer="$3"

#-------------------------
#INITIALIZE A RANDOM DUNGEON
# - CHECK BOUNDS
# - CHECK NEIGHBORS
# - NOT MY BEST WORK BUT IM LEARNING
#-------------------------

reset_rand_event_arrays(){

    declare -gA random_dungeon_events=(
        [abandoned_camp_state]=0
        [abandoned_camp_looted]=0
        [abandoned_camp_location]=""
        [abandoned_camp_desc]="A cold campfire smolders in the darkness.

    Someone left in a hurry, leaving behind some of
    their belongings."
        [abandoned_camp_looted_desc]="A cold campfire smolders in the darkness.

    It's been picked clean. Only smoldering coals
    remain."
        [forgotten_cache_state]=0
        [forgotten_cache_looted]=0
        [forgotten_cache_location]=""
        [forgotten_cache_desc]="You discover a loose stone in the wall."
        [forgotten_cache_looted_desc]="An empty cache remains where you removed the stone."

        [mana_spring_state]=0
        [mana_spring_looted]=0
        [mana_spring_location]=""
        [mana_spring_desc]="Blue water bubbles from a crack in the stone."
        [mana_spring_looted_desc]="Blue water trickles from a crack in the stone.
It gives off a faint glow in the surrounding darkness."

        [shrine_state]=0
        [shrine_looted]=0
        [shrine_location]=""
        [shrine_desc]="A weathered shrine stands untouched by time. It hums with ancient power."
        [shrine_looted_desc]="The weathered shrine has fallen silent."

    )

    declare -ga random_dungeon_events_array=(
        "abandoned_camp"
        "forgotten_cache"
        "mana_spring"
        "shrine"
    )
}

clear_desc_newline(){
    clear
    desc_newline
    echo
}

random_minor_loot(){
    local -a items=(
    ale
    apple
    stale_bread
    ironwill_stout
    minor_health_potion
    minor_mana_potion
    )

    local poor=3
    local min=3
    local max=$(( ${#items[@]} - 1 ))
    local winning_index

    if (( RANDOM % 100 < 70 ));then
        winning_index=$(( RANDOM % poor ))
    else
        winning_index=$(( RANDOM % (max - min + 1) + min ))
    fi

    echo "${items[$winning_index]}"
}

shrine_handler(){
    if [[ "${random_dungeon_events[shrine_looted]}" == 0 ]];then
        random_dungeon_events[shrine_looted]=1
        clear_desc_newline
        printf "%b\n" "${ITALIC}You bow your head before the ancient shrine.

${BLINK}A warm light washes over you, filling you with renewed strength!${RESET}"
        (( player_health = max_health ))
        echo
        press_any_to_continue
    else
        clear_desc_newline
        printf "%b\n" "${ITALIC}You kneel before the shrine.
Nothing answers your silent prayer.${RESET}"
    fi
}

mana_spring_handler(){
    if [[ "${random_dungeon_events[mana_spring_looted]}" == 0 ]];then
        random_dungeon_events[mana_spring_looted]=1
        clear_desc_newline
        printf "%b\n" "${ITALIC}You kneel beside the spring and cup the shimmering water
in your hands.

${BLINK}The cool water restores your ${BLUE}mana!${RESET}"
        (( player_mana = max_mana ))
        echo
        press_any_to_continue
    else
        clear_desc_newline
        printf "%b\n" "${ITALIC}You kneel beside the spring.
Only a few drops remain. The spring needs time to recover.${RESET}"
    fi
}

abandoned_camp_handler(){

    local winning_item
    winning_item=$(random_minor_loot)
    local display_item="${winning_item//_/ }"
    if [[ "${display_item:0:1}" =~ [AEIOUaeiou] ]];then
        display_item="an ${display_item}"
    else
        display_item="a ${display_item}"
    fi

    if [[ "${random_dungeon_events[abandoned_camp_looted]}" == 0 ]];then
        random_dungeon_events[abandoned_camp_looted]=1
        clear_desc_newline
        printf "%b\n" "${ITALIC}${REVERSE}You loot the abandoned camp.
You find $display_item!${RESET}"
        add_item_handler "${winning_item}"
        echo
        press_any_to_continue
    else
        clear_desc_newline
        printf "%b\n" "${ITALIC}There is nothing left to take..${RESET}"
    fi
}

forgotten_cache_handler(){
    local winning_item
    winning_item=$(random_minor_loot)
    local display_item="${winning_item//_/ }"
    if [[ "${display_item:0:1}" =~ [AEIOUaeiou] ]];then
        display_item="an ${display_item}"
    else
        display_item="a ${display_item}"
    fi

    local attacked="$1"
    #bird nest time baby
    if [[ "${random_dungeon_events[forgotten_cache_looted]}" == 0 ]];then
        random_dungeon_events[forgotten_cache_looted]=1
        clear_desc_newline
        if [[ "${attacked}" == "attacked" ]];then
            printf "%b\n" "${ITALIC}${REVERSE}You pulverize the loose stone.
Behind it rests a small hidden cache.

You find $display_item!${RESET}"
            add_item_handler "${winning_item}"
            echo
            press_any_to_continue
        else
            printf "%b\n" "${ITALIC}${REVERSE}You pull the loose stone free.
Behind it rests a small hidden cache.
You find $display_item!${RESET}"
            add_item_handler "${winning_item}"
            echo
            press_any_to_continue
        fi
    else
        clear_desc_newline
        printf "%b\n" "${ITALIC}There is nothing left to take..${RESET}"
    fi
}

check_for_random_event(){
    local event
    for event in "${random_dungeon_events_array[@]}";do
        local key_location="${event}_location"
        local key_description="${event}_desc"
        local key_looted_check="${event}_looted"
        local key_looted_desc="${event}_looted_desc"

        if [[ "${random_dungeon_events[$key_location]}" == "${location}" ]];then
            current_event="${event}"
            if [[ "${random_dungeon_events[$key_looted_check]}" == 0 ]];then
                printf "\n%s\n" "${random_dungeon_events[$key_description]}"
                return
            else
                printf "\n%s\n" "${random_dungeon_events[$key_looted_desc]}"
                return
            fi
        else
            current_event=""
        fi
    done
}

random_dungeon_init() {
    up() {
    if (( ${r} - 1 < ${bt} )); then
        :
        else
            nu="$(( r - 1 )),$c"
            exists=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nu" == "${rooms[i]}" ]]; then
                        exists=true
                        break
                    fi
                done

                if [[ $exists == false ]]; then
                    room_candidate+=("$nu")
                fi
    fi   
    }

    down() {
    if (( ${r} + 1 >= ${bb} )); then
            :
        else
            nu="$(( r + 1 )),$c"
            exists=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nu" == "${rooms[i]}" ]]; then
                        exists=true
                        break
                    fi
                done

                if [[ $exists == false ]]; then
                    room_candidate+=("$nu")
                fi
    fi   
    }

    left () {
    if (( ${c} - 1 < ${bl} )); then
            :
        else
            nu="$r,$(( c - 1 ))"
            exists=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nu" == "${rooms[i]}" ]]; then
                        exists=true
                        break
                    fi
                done

                if [[ $exists == false ]]; then
                    room_candidate+=("$nu")
                fi
    fi   
    }

    right() {
    if (( ${c} + 1 >= ${br} )); then
           :
        else
            nu="$r,$(( c + 1 ))"
            exists=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nu" == "${rooms[i]}" ]]; then
                        exists=true
                        break
                    fi
                done

                if [[ $exists == false ]]; then
                    room_candidate+=("$nu")
                fi
    fi   
    }

#-------------------------
#EXEC CHECKS
#-------------------------

up
down
left
right
}

#-------------------------
#BREED ROOMS FROM PATIENT ZERO
#-------------------------

room_breeder() {

    r=$1
    c=$2

    up() {
    if (( ${r} - 1 < ${bt} )); then
        :
        else
            nu="$(( r - 1 )),$c"
            exists=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nu" == "${rooms[i]}" ]]; then
                        exists=true
                        break
                    fi
                done

                if [[ $exists == false ]]; then
                    room_candidate+=("$nu")
                fi
    fi
    }

    down() {
    if (( ${r} + 1 >= ${bb} )); then
            :
        else
            nu="$(( r + 1 )),$c"
            exists=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nu" == "${rooms[i]}" ]]; then
                        exists=true
                        break
                    fi
                done

                if [[ $exists == false ]]; then
                    room_candidate+=("$nu")
                fi
    fi   
    }

    left () {
    if (( ${c} - 1 < ${bl} )); then
            :
        else
            nu="$r,$(( c - 1 ))"
            exists=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nu" == "${rooms[i]}" ]]; then
                        exists=true
                        break
                    fi
                done

                if [[ $exists == false ]]; then
                    room_candidate+=("$nu")
                fi
    fi   
    }

    right() {
    if (( ${c} + 1 >= ${br} )); then
           :
        else
            nu="$r,$(( c + 1 ))"
            exists=false
                for (( i=0; i<${#rooms[@]}; i++ )); do
                    if [[ "$nu" == "${rooms[i]}" ]]; then
                        exists=true
                        break
                    fi
                done

                if [[ $exists == false ]]; then
                    room_candidate+=("$nu")
                fi
    fi   
    }
up
down
left
right
}

#-------------------------
#DEBUGGING TEXT
#-------------------------

debug_dungeon(){
echo "hod $hod"
echo "wod $wod"
echo "br aka wod $br"
echo "bb aka hod $bb"
echo "max rooms: $max_rooms"
echo "random_r: $random_r random_c: $random_c"
echo "room_zero: $room_zero"
echo "array: ${rooms[*]}"
echo "r=$r c=$c"
echo
echo "${in_progress_random_dungeon[total_enemies]}"
echo "${in_progress_random_dungeon[enemies_killed]}"
echo "exit = $EXIT"
}

#-------------------------
#DUNGEON MAP
#WAS FOR DEBUGGING BUT MIGHT USE IN GAME
#-------------------------

draw_dungeon() {

    for (( row=0; row<hod; row++ )); do
        for (( col=0; col<wod; col++ )); do

            cell="$row,$col"
            is_room=false

            for (( i=0; i<${#rooms[@]}; i++ )); do
                if [[ "$cell" == "${rooms[i]}" ]]; then
                    is_room=true
                    break
                fi
            done

            # player > room > empty
            if [[ "$location" == "$cell" ]]; then
                printf "♞ "
            elif [[ $is_room == true ]]; then
                printf "■ "
            else
                printf "□ "
            fi

        done
        echo
    done
    debug_dungeon
}

#-------------------------
#ROOMS PLAY A LOTTERY TO SEE IF THEY GET GENERATED
#-------------------------

candidate_lottery() {
    
    if (( ${#rooms[@]} >= max_rooms )); then
        return
    fi

    if (( ${#rooms[@]} < ${max_rooms} )); then
        created_new_rooms=false
        winning_number=$(( RANDOM % birth_chance + 1 ))
            for (( i=0; i<${#room_candidate[@]}; i++ )); do
                room_gamble=$(( RANDOM % birth_chance + 1 ))
                if [[ "${room_gamble}" == "${winning_number}" ]]; then
                    rooms+=("${room_candidate[i]}")
                    rooms_to_be_bred+=("${room_candidate[i]}")
                    created_new_rooms=true
                fi
            done
    fi

if (( ${#room_candidate[@]} == 0 )); then
    # pick a random existing room and try again basically force one
    
    idx=$(( RANDOM % ${#rooms[@]} ))
    r=${rooms[idx]%%,*}
    c=${rooms[idx]##*,}

    room_candidate=()
    random_dungeon_init
    candidate_lottery
    return
fi

    # breed next generation
    room_candidate=()

    for (( i=0; i<${#rooms_to_be_bred[@]}; i++ )); do
        room_breeder \
            "${rooms_to_be_bred[i]%%,*}" \
            "${rooms_to_be_bred[i]##*,}"
    done

    rooms_to_be_bred=()

    candidate_lottery
    
}     

#-------------------------
#FILL RANDO DUNGEON WITH ROOM DESCRIPTIONS AND STUFF
#-------------------------

scatter_materials() {
    local loop_bag="${in_progress_random_dungeon[material_amount]}"
    local scatter
    local room_idx
    local sel_room

    while (( loop_bag > 0 )); do
        room_idx=$(( RANDOM % ${#rooms[@]} ))
        sel_room=${rooms[$room_idx]}

        scatter=$(( RANDOM % loop_bag + 1 ))

        (( has_material[$sel_room] += scatter ))
        (( loop_bag -= scatter ))
    done
}

scatter_rescue(){
    local rescue_person="${in_progress_random_dungeon[rescue_name]}"
    rescue_person="${rescue_person// /_}"
    rescue_person="${rescue_person,,}"
    local room_idx=$(( RANDOM % ${#rooms[@]} ))
    local sel_room=${rooms[$room_idx]}
    in_progress_random_dungeon[rescue_location]="${sel_room}"
    item_type[$rescue_person]="minor_quest_item"
    local rescue_desc_idx=$(( RANDOM % ${#rescue_desc_array[@]} ))
    local rescue_desc="${rescue_desc_array[$rescue_desc_idx]}"
    minor_quest_item_data["${rescue_person}_description"]="${rescue_desc}"
}

shuffle_array() {
    local array_name="$1"
    declare -n arr="$array_name"

    local i j temp

    for (( i=${#arr[@]}-1; i>0; i-- )); do
        j=$(( RANDOM % (i + 1) ))

        temp="${arr[i]}"
        arr[i]="${arr[j]}"
        arr[j]="$temp"
    done
}

scatter_events(){
    (( ${#rooms[@]} == 0 )) && return

    reset_rand_event_arrays
    local events=$(( RANDOM % ${#rooms[@]} + 1 ))
    shuffle_array random_dungeon_events_array
    local event_array_size=${#random_dungeon_events_array[@]}
    local shuffled_rooms=("${rooms[@]}")
    shuffle_array shuffled_rooms

    if (( events > event_array_size ));then
        events=$event_array_size
    fi

    local i
    for ((i=0;i<events;i++));do
        local key="${random_dungeon_events_array[$i]}_location"
        random_dungeon_events[$key]="${shuffled_rooms[$i]}"
    done
}

rand_theme_and_fill() { 
    if [[ -z "$1" ]]; then
        selected_theme_idx=$(( RANDOM % ${#all_themes[@]} ))
        selected_theme="${all_themes[$selected_theme_idx]}"
        declare -n current_theme="$selected_theme"
    else
        selected_theme="$1"
        declare -n current_theme="$selected_theme"
    fi

    banner_title="$selected_theme"

    # Build index list
    indices=()
    for (( i=0; i<${#current_theme[@]}; i++ )); do
        indices+=("$i")
    done

    # shuffle that shit
    shuffle_array indices

    for (( i=0; i<${#rooms[@]}; i++ )); do

        room="${rooms[i]}"

        # Wrap if more rooms than descriptions
        idx="${indices[i % ${#indices[@]}]}"

        tmp_desc_pick="${current_theme[$idx]}"
        description_key="${room},description"

        random_dungeon_properties["$description_key"]="$tmp_desc_pick"

    done

    EXIT_IDX=$(( RANDOM % "${#rooms[@]}" ))
    EXIT="${rooms[$EXIT_IDX]}"
    in_progress_random_dungeon[material_collected]=0
    in_progress_random_dungeon[enemies_killed]=0
    scatter_materials
    scatter_rescue
    scatter_events
}
#-------------------------
#EXEC
#-------------------------

random_dungeon_init
candidate_lottery
rand_theme_and_fill "${themer}"


}

random_dungeon_spawner() {
    local amount_of_enemies="${in_progress_random_dungeon[total_enemies]}"
    local killed="${in_progress_random_dungeon[enemies_killed]}"
    if (( killed < amount_of_enemies )); then
        case "$combat_rank" in
            F)
                if [[ "$location_rd_prev" != "$location" ]]; then

                    spawn_winning_roll=$(( RANDOM % $f_spawn_chance ))
                    spawn_player_roll=$(( RANDOM % $f_spawn_chance ))

                    if (( spawn_player_roll == spawn_winning_roll )); then
                        clear
                        state="combat"
                    fi

                    # update AFTER checking
                    location_rd_prev="$location"
                fi
            ;;

            E)
                if [[ "$location_rd_prev" != "$location" ]]; then

                    spawn_winning_roll=$(( RANDOM % $e_spawn_chance ))
                    spawn_player_roll=$(( RANDOM % $e_spawn_chance ))

                    if (( spawn_player_roll == spawn_winning_roll )); then
                        clear
                        state="combat"
                    fi

                    # update AFTER checking
                    location_rd_prev="$location"
                fi
            ;;
        esac
    fi
}

