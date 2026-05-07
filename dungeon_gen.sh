#!/usr/bin/env bash

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

#-------------------------
#INITIALIZE A RANDOM DUNGEON
# - CHECK BOUNDS
# - CHECK NEIGHBORS
# - NOT MY BEST WORK BUT IM LEANING
#-------------------------

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

# echo "hod $hod"
# echo "wod $wod"
# echo "br aka wod $br"
# echo "bb aka hod $bb"
# echo "max rooms: $max_rooms"
# echo "random_r: $random_r random_c: $random_c"
# echo "room_zero: $room_zero"
# echo "array: ${rooms[*]}"
# echo "r=$r c=$c"
# echo
# echo
# random_dungeon_init

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

            # 🔥 PRIORITY: player > room > empty
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

rand_theme_and_fill() {
    if [[ -z "$1"]]; then
        selected_theme_idx=$(( RANDOM % ${#all_themes[@]} ))
        selected_theme="${all_themes[$selected_theme_idx]}"
        declare -n current_theme="$selected_theme"
    else
        selected_theme="$1"
        declare -n current_theme="$selected_theme"
    fi
    
    banner_title="${selected_theme}"

    # build index list
    indices=()
    for (( i=0; i<${#current_theme[@]}; i++ )); do
        indices+=("$i")
    done

    # shuffle once
    shuffled=($(printf "%s\n" "${indices[@]}" | shuf))

    for (( i=0; i<${#rooms[@]}; i++ )); do
        
        room="${rooms[i]}"

        # wrap if more rooms than descriptions
        idx="${shuffled[i % ${#shuffled[@]}]}"

        tmp_desc_pick="${current_theme[$idx]}"
        description_key="${room},description"

        random_dungeon_properties["$description_key"]="$tmp_desc_pick"

    done
}
#-------------------------
#EXEC
#-------------------------

random_dungeon_init
candidate_lottery
rand_theme_and_fill


}

random_dungeon_spawner() {
    case "$combat_rank" in
        F)
            if [[ "$location_rd_prev" != "$location" ]]; then

                spawn_winning_roll=$(( RANDOM % 5 ))
                spawn_player_roll=$(( RANDOM % 5 ))

                if (( spawn_player_roll == spawn_winning_roll )); then
                    clear
                    state="combat"
                fi

                # update AFTER checking
                location_rd_prev="$location"
            fi
        ;;
    esac
}

