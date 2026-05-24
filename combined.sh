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
echo -e "${REVERSE} GOLD: $player_gold ${RESET}" 
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
#!/usr/bin/env bash

waiting_chat(){
printf '\e[?25l'
for (( i=0; i<3; i++ )); do
    printf "."
    sleep 0.7
done
echo
printf '\e[?25h'
}
stored_chat_update() {

#-------------------------
#CHAT
#-------------------------
declare -gA tutorial=(

[character_screen]="After leaving this page you will be viewing your character screen.
The character screen is not only an overview of your stats, 
and current buffs/debuffs.

It's also how you'll allocate points gained 
by leveling up to increase your stats.

Here's a quick overview of how stat points work: 
${DIM}${BLINK} You can always review these from the game manual. ${RESET}

${BOLD}Determination:${RESET} For every 10 points in determination 
you'll receive 1 ${ITALIC}skill${RESET} point added to your maximum skill points.

${BOLD}Strength:${RESET} For every 3 points in stength 
you'll receive 1 ${ITALIC}attack${RESET} point added to your maximum attack.

${BOLD}Intelligence:${RESET} For every point in intelligence 
you'll receive 3 points of maximum ${ITALIC}mana${RESET}.
"
[quest_board_how_to]="${DIM}NEW ADVENTURERS READ: ONLY ONE MINOR QUEST CAN BE HELD AT A TIME
MINOR QUEST CAN BE ACCESSED THROUGH A GUILD PORTAL
COMPLETED QUEST SHOULD BE TURNED INTO THE GUILD CLERK${RESET}"
)
declare -gA fandor_guild=(

[clerk_introduction]="The clerk is wearing a cornwall blue dress that's been well worn. 
She looks up at you, but you feel like she is looking through you as 
if you are invisible.

Registration, collection, or just here to bother me?
"

[clerk_collection]="I only deal with registered adventurers."

[clerk_class]="She drags a quill across the page without looking up. 
\"Alright… you wrote down ${name}. That’s something.\"

A pause. She squints at the parchment like it personally offended her.

\"Now I need a class. Try to pick one without wasting both of our time.\"
She finally glances up at you—tired, unimpressed.

\"Go on. What are you?\"


${BOLD}W)arrior${RESET} — Front line. Steel, muscle, and bad decisions. 
You’ll hit harder the more experienced you get.

${BOLD}C)leric${RESET} — Keep people alive. Or try to. 
More durable than you look, if you stick with it.

${BOLD}M)age${RESET} — Books, spells, and things catching fire. 
Your mana pool will grow fast.

${BOLD}P)aladin${RESET} — Bit of everything. Discipline, control… 
and a tendency to think you’re right.


She taps the page impatiently. \"Well?\"

"
[clerk_race]="She flips to the next page with a sharp flick of her wrist.
\"Race. Try not to make this one complicated.\"
Her eyes scan you quickly, like she’s already made up her mind 
and just needs it confirmed.

${DIM}Race won't have any effect on gameplay 
but could lead to some different social interactions.${RESET}


${BOLD}H)uman${RESET} — \"Reliable. Adaptable. Everywhere. 
You’ll fit in just fine.\"

${BOLD}E)lf${RESET} — \"Graceful, long-lived… and usually aware of it. 
Try not to look down on everyone.\"

${BOLD}D)warf${RESET} — \"Stubborn, tough, and loud about both. 
At least you’ll survive.\"

${BOLD}O)rc${RESET} — \"Strong. Direct. People will assume things. 
They’re not always wrong.\"

${BOLD}Hf)Halfling${RESET} — \"Small, quiet, and underestimated. 
Probably the smartest way to stay alive, honestly.\"


She taps the quill against the page, once… twice…

\"Well?\"
"

[clerk_reg_finished]="She finishes writing and sets the quill down with a quiet sigh.
\"Alright… that’s you sorted.\"

She looks up for a moment, studying you.

\"Try to keep yourself alive. We lose enough people as it is.\"
A small pause. \"Good luck out there.\"

${DIM}${BLINK}TUTORIAL: Type 'goodbye' to finish interacting with someone.${RESET}
"
#01clerk chatting

[clerk_default_1]="The clerk barely looks up from the papers scattered across the counter.
${RESET}\"What do you want, ${name}?\"${RESET}"

[clerk_default_2]="She flips through a ledger with practiced impatience.
${RESET}\"If you're here for work, ask about questing. 
If you've finished something, collect your reward and move along.\"${RESET}"

[clerk_collect_success_neutral]="The clerk reviews your papers, then gives a small nod.
\"Looks legitimate enough.\"

She reaches beneath the counter and returns with your payment.
\"Keep them coming.\" The clerk hands you:"

[clerk_collect_failure_neutral]="The clerk glances over your records before sliding them back.
\"Nothing completed.\"

She dips her quill into ink and resumes writing.
\"Come back when you've actually finished something, ${name}.\""

#01training dummy chatting

[dummy_default_1]="You attempt conversation with the dummy.
Several nearby adventurers pretend not to notice."

[dummy_default_2]="You try speaking to the dummy.
A passing recruit quietly picks up their pace."

[dummy_default_3]="You attempt to converse with the dummy.
This explains a lot, honestly."

[dummy_default_4]="You ask the training dummy a question.
The dummy's silence feels judgmental."

)

}

stored_chat_update#!/usr/bin/env bash

mapfile -t random_e_death < death.txt

#gold loot

random_gold(){
    local max="$1"
    local min="$2"
    
    echo "$(( RANDOM % ($max - $min + 1 ) + $min ))"
}
enemy_loot(){
    case $combat_rank in
    S) local gold_gain="$(random_gold 250 190)" ;;
    A) local gold_gain="$(random_gold 190 100)" ;;
    B) local gold_gain="$(random_gold 100 60)" ;;
    C) local gold_gain="$(random_gold 60 40)" ;;
    D) local gold_gain="$(random_gold 40 22)" ;;
    E) local gold_gain="$(random_gold 22 10)" ;;
    F) local gold_gain="$(random_gold 10 3)" ;;
    Z) local gold_gain=500 ;;
esac

echo "$gold_gain"

}

#update ename

enemy_dead_screen(){
clear

local death="${random_e_death[RANDOM % ${#random_e_death[@]}]}"
local display_death="${death//\$ename/$ename}"

case $combat_rank in
    S) local xp_gain=430 ;;
    A) local xp_gain=360 ;;
    B) local xp_gain=210 ;;
    C) local xp_gain=160 ;;
    D) local xp_gain=60 ;;
    E) local xp_gain=30 ;;
    F) local xp_gain=10 ;;
    Z) local xp_gain=500 ;;
esac

(( player_xp += xp_gain ))
local gold_gain="$(enemy_loot)"
(( player_gold += $gold_gain ))

echo "$display_death"
echo
echo "Through your efforts you gain $xp_gain points of experience"
echo "The $ename drops $gold_gain gold coins"
echo ; echo
echo -e "${REVERSE}EXPERIENCE: $player_xp/$xp_to_next_level GOLD: $player_gold${RESET}"
echo

}
#!/usr/bin/env bash

name="jane doe"
name_fixed=""
for word in $name;do
    name_fixed+="${word^} "
done
name="${name_fixed% }"
echo "$name"
#!/usr/bin/env bash
prev_dummy_chat=""

clerk_lick() {
    if (( clerk_lick_tries == 0 ));then
        desc_newline
        echo -e "${ITALIC}${taste_data[$noun]}${RESET}"
        clerk_lick_tries=1
        return
    fi

    if (( clerk_lick_tries == 1 ));then
        desc_newline
        echo -e "${ITALIC}The clerk punches you in the face... You deserve it creep!${RESET}"
        hurt_player 3
        clerk_lick_tries=0
        return
    fi    
}

dummy_chat(){
local chatdex=$(( RANDOM % 4 + 1 ))
if (( prev_dummy_chat == chatdex ));then
    dummy_chat
else
    prev_dummy_chat=$chatdex
    echo -e "${fandor_guild[dummy_default_$chatdex]}"
fi
}  #!/usr/bin/env bash

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
    scatter_materials
    scatter_rescue
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

#!/usr/bin/env bash

#-------------------------
#[ Z ] SPECIAL ENEMIES
#-------------------------

z_rank_spawner() {

declare -gA z_rank_enemies=(

[DUMMY]=9999

)

ename=$1
ehp=${z_rank_enemies[$ename]}

}


#-------------------------
#[ F ] RANK ENEMIES
#-------------------------

f_rank_spawner() {

f_rank_hp_mod=$(( RANDOM % (31 - 10 + 1) + 10 ))

declare -gA f_rank_enemies=(

[Orc]=$(( 30 + f_rank_hp_mod ))
[Goblin]=$(( 20 + f_rank_hp_mod ))
[Bandit]=$(( 15 + f_rank_hp_mod ))

)

enemy_array=("${!f_rank_enemies[@]}")
random_enemy="${enemy_array[RANDOM % ${#enemy_array[@]}]}"

ename="${random_enemy}"
ehp=${f_rank_enemies[$random_enemy]}

}

#-------------------------
#[ E ] RANK ENEMIES
#-------------------------

e_rank_spawner() {

e_rank_hp_mod=$(( RANDOM % (31 - 10 + 1) + 10 ))

declare -gA e_rank_enemies=(

[Hobgoblin]=$(( 80 + e_rank_hp_mod ))
[Undead Skeleton]=$(( 60 + e_rank_hp_mod ))
[Shadow]=$(( 50 + e_rank_hp_mod ))

)

enemy_array=("${!e_rank_enemies[@]}")
random_enemy="${enemy_array[RANDOM % ${#enemy_array[@]}]}"

ename="${random_enemy}"
ehp=${e_rank_enemies[$random_enemy]}


}

#-------------------------
#ENEMY NARRATIVES 
#THESE WOULD PROBABLY BE BETTER AS A TEXT FILE OR SOMETHING
#-------------------------

declare -gA hobgoblin_narrative=(

[hobgoblin_0]="The hobgoblin cracks a cruel grin, already certain you will break before it does."
[hobgoblin_1]="A hobgoblin pounds its chest and snarls—discipline and brutality in equal measure."
[hobgoblin_2]="The hobgoblin sneers, sizing you up like you are barely worth the effort."

)

declare -gA undead_skeleton_narrative=(

[undead_skeleton_0]="The skeleton rattles forward, its empty grin promising a very personal haunting."
[undead_skeleton_1]="Bones clatter as it rises—apparently death was not a strong enough hint."
[undead_skeleton_2]="The skeleton tilts its skull at you, as if wondering how you'll look without skin."

)

declare -gA orc_narrative=(

[orc_0]="The orc bares its tusks and laughs—you’re tonight’s entertainment."
[orc_1]="An orc stomps forward, cracking its neck like your bones are next."
[orc_2]="The orc rolls its shoulders and chuckles—you might last a whole two swings."

)

declare -gA goblin_narrative=(

[goblin_0]="The goblin snickers, clutching a rusty blade like it’s already claimed your pockets."
[goblin_1]="A goblin darts in, eyes gleaming—equal parts cowardice and bad intentions."
[goblin_2]="The goblin grins with too many teeth, clearly excited about your misfortune."

)

declare -gA bandit_narrative=(

[bandit_0]="The bandit tips his hat with a smirk—your coin or your blood, he’s not picky."
[bandit_1]="A bandit steps from the shadows, already counting what you’re worth."
[bandit_2]="The bandit chuckles under his breath—easy work always puts him in a good mood."

)

declare -gA shadow_narrative=(

[shadow_0]="The shadow stretches toward you, as if eager to wear your shape next."
[shadow_1]="A shadow slips closer, silent and certain—you’re already halfway gone."
[shadow_2]="The darkness gathers itself into form, and somehow… it’s looking right at you."

)#!/usr/bin/env bash

#-------------------------
#FLEE RANDOM TEXT
#-------------------------

flee=(
$'(your courage falls to the ground)\nYou abandon honor and run!'
$'(you e scape)...\n...but the bards will sing of this cowardice.'
$'The enemy watches you run...\n"Pathetic."'
$'(you begin crying obnoxiously)\nThe enemy is confused, and lets you run away.'
$'(you run away bravely...)\n...in the opposite direction.'
$'(you flee with great speed...)\nand even greater shame.'
$'(your legs fight harder than you did.)\nThey win.'
$'(you retreat!)\nTactically!\nVery, very far away.'
$'(you escape...)\nDignity not included.'
$'(you run like your life depends on it.)\n(It does.)'
$'(you flee.)\nThe enemy is not impressed.'
$'(you make a strategic withdrawal...)\nInto cowardice.'
$'(you run so fast...)\nYou almost look competent.'
$'(you escape, leaving behind your pride...)\nAnd possibly your lunch.'
$'(you flee!)\nEven your shadow refuses to follow.'
$'(you turn tail and sprint...)\nLike a startled chicken.'
$'(you run.)\nThe bards will have a field day with this.'
$'(you escape...)\nAnd immediately regret everything about yourself.'
$'(you flee!)\nSomewhere, a hero shakes their head in disappointment.'
$'(you run screaming into the darkness.)\nBold choice.'
$'(you escape.)\nThe enemy didn’t even bother chasing you.'
$'(you flee!)\nYour ancestors collectively sigh.'
$'(you run like you’ve done this before.)\nThat’s not a good thing.'
$'(you escape!)\nYour reputation does not.'
)

#REMOVE THIS
# flee_state_handler(){
# clear
# rand=$(( RANDOM % ${#flee[@]} ))
# echo -e "${flee[$rand]}"
# echo -e "\n\n"
# read -r -p 'PRESS ANY ENTER TO CONTINUE' 
# state="nav" 
# }#!/usr/bin/env bash

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

#-------------------------
#DESCRIBE ROOM
#-------------------------

desc_room() {
    [[ ${in_random_dungeon} == false ]] && echo -e "${room_desc[$location]}"
    [[ ${in_random_dungeon} == true ]] && theme_banner="${banner_title//_/ }" && theme_banner="${theme_banner^^}" && echo -e "\e[7m${theme_banner}\e[0m\n" && 
    [[ ${in_random_dungeon} == true ]] && echo "${random_dungeon_properties["$location,description"]}" && check_for_material && check_for_rescue
 
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
        flee_success=false
        show_active_quest
    fi
}

desc_newline(){
    desc_room
    echo  
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
                    add_item_handler "${in_progress_random_dungeon[material]}"
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
                add_item_handler "${in_progress_random_dungeon[rescue_name]}"
                in_progress_random_dungeon[rescue_location]=""
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
        *dummy*:"fandor_gh_outside")
            combat_rank="Z"
            state="combat"
        ;;


        *portal*:"fandor_gh_outside")
            use_portal
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
            clear ; stored_chat_update
            echo -e "${fandor_guild[clerk_default_1]}"
            waiting_chat
            wait
            echo -e "${fandor_guild[clerk_default_2]}"
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
                echo -e "Of course you are. \nShe hands you a document, dips a quill in ink and hands it you."
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
esac

case $verb:$who in


    *collect*:"clerk")
        if [[ "${in_progress_random_dungeon[state]}" == "complete" ]];then
            echo -e "${fandor_guild[clerk_collect_success_neutral]}"

            combat_rank_lower_cased="${in_progress_random_dungeon[rank],,}"

            gold_reward="${combat_rank_lower_cased}_rank_quest_gold"
            xp_reward="${combat_rank_lower_cased}_rank_quest_xp"
            
            echo
            echo -e "A pouch containing ${YELLOW}${quest_rewards[$gold_reward]} gold coins.${RESET}"
            echo -e "You feel more experienced. ${MAGENTA}${quest_rewards[$xp_reward]} experience gained.${RESET}"

            (( player_gold += quest_rewards[$gold_reward] ))
            (( player_xp += quest_rewards[$xp_reward] ))

            in_progress_random_dungeon=()
            in_progress_random_dungeon[state]=false

        else
            echo -e "${fandor_guild[clerk_collect_failure_neutral]}"
        fi

    ;;

    *:"clerk")
    echo "You're not from around here are you?"
    echo
    echo -e "${fandor_guild[clerk_default_2]}"
    ;;

    *:"dummy")
    dummy_chat
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
    if [[ "${in_progress_random_dungeon[type]}" == "CLEAR ALL MONSTERS" ]];then
        if (( "${in_progress_random_dungeon[enemies_killed]}" >= "${in_progress_random_dungeon[total_enemies]}" ));then
            in_progress_random_dungeon[state]="complete"
        fi    
    elif [[ "${in_progress_random_dungeon[type]}" == "COLLECT" ]];then
        if (( "${in_progress_random_dungeon[material_collected]}" >= "${in_progress_random_dungeon[material_amount]}" ));then
            in_progress_random_dungeon[state]="complete"
        fi
    fi
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


}#!/usr/bin/env bash

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
        display_key="${display_key,,}"
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
#!/usr/bin/env bash

declare -gA item_type=(
    [short_sword]="weapon"
    [cloth_tunic]="armor"
    [necklace_of_life]="accessory"
    [necklace_of_mana]="accessory"    
    [apple]="consumable"
    [lever]="object"
    [goblin_ear]="minor_quest_item"
    [troll_toenail]="minor_quest_item"
    [mana_crystal]="minor_quest_item"
    [bottled_tear]="minor_quest_item"
    [whispering_shard]="minor_quest_item"
    [screaming_crystal]="minor_quest_item"
    [gravemoss]="minor_quest_item"
    [witchroot]="minor_quest_item"
    [bloodmint]="minor_quest_item"
    [ceremonial_spoon]="minor_quest_item"
    [ancient_scroll]="minor_quest_item"
    [cracked_idol]="minor_quest_item"
    [ominous_teaspoon]="minor_quest_item"
    [insect_molt]="minor_quest_item"
    [slime_core]="minor_quest_item"
)

declare -gA weapon_data=(
    [short_sword_damage]=5
    [short_sword_description]="The blade is roughly forged but will get the job done."
    [short_sword_value]=10

)

declare -gA armor_data=(
    [cloth_tunic_defense]=1
    [cloth_tunic_description]="A cheap tunic made of cloth."
    [cloth_tunic_value]=2
    
)

declare -gA accessory_data=(
    [necklace_of_life_modify_variable]="bonus_health"
    [necklace_of_life_modify_value]=10
    [necklace_of_life_description]="A silver necklace with a radiating ruby in the shape of a heart."
    [necklace_of_life_effects]="Raises maximum health by: 10"
    [necklace_of_life_value]=50

    [necklace_of_mana_modify_variable]="bonus_mana"
    [necklace_of_mana_modify_value]=10
    [necklace_of_mana_description]="A gold necklace with a vibrant sapphire in the shape of an orb."
    [necklace_of_mana_effects]="Raises maximum mana by: 10"
    [necklace_of_mana_value]=50
)

declare -gA consumable_data=(
    [apple_modify_variable]="player_health"
    [apple_modify_value]=5
    [apple_description]="Fruit with red or yellow or green skin and sweet to tart crisp whitish flesh."
    [apple_value]=1
)

declare -gA object_data=(
    [lever_description]="A sturdy lever, what does it do? Who knows..."
)

declare -gA minor_quest_item_data=(
    [goblin_ear_description]="A shriveled goblin ear, still reeking of damp caves."
    [troll_toenail_description]="A thick troll toenail chipped from some hulking brute."
    [mana_crystal_description]="A glowing crystal humming softly with raw arcane energy."
    [bottled_tear_description]="A tiny glass vial holding a single shimmering tear."
    [whispering_shard_description]="Faint whispers slither from the jagged black shard."
    [screaming_crystal_description]="A crimson crystal that emits distant muffled screams."
    [gravemoss_description]="Cold gray moss gathered from ancient burial stones."
    [witchroot_description]="A twisted root pulsing faintly with unnatural warmth."
    [bloodmint_description]="Dark red mint leaves carrying a sharp metallic scent."
    [ceremonial_spoon_description]="An engraved spoon once used in strange sacred rites."
    [ancient_scroll_description]="A brittle scroll covered in faded forgotten script."
    [cracked_idol_description]="A fractured idol staring ahead with hollow stone eyes."
    [ominous_teaspoon_description]="A tarnished teaspoon radiating quiet unsettling dread."
    [insect_molt_description]="A brittle shell shed by some massive crawling insect."
    [slime_core_description]="A wobbling core of dense slime pulsing with ooze."
)

declare -gA taste_data=(
    [short_sword]="You drag your tongue from hilt to tip. Weirdo. It tastes sharply metallic."
    [long_sword]="You give the longer blade an experimental lick. Same sword taste, just more of it."
    [war_axe]="You lean in and give the axe a quick lick. It tastes like violence and poor impulse control."
    [twin_daggers]="You give each dagger a quick taste, as if one might be flavored differently. It is not."
    [sebilles_claymore]="You drag your tongue across the blade. Some relics are meant to inspire awe. 
    Y o u . . . c h o s e . . . t h i s . . ."
    [apple]="You give it a lick. It's an apple, not a mystery."
    [bread]="Your tongue brushes the crust. Crunchy outside, warm inside. Not your worst decision."
    [pie]="You sample the edge of the pie. Sugar, spice, and absolutely no regrets."
    [health_potion]="You lick the bottle like you're unsure of its contents. It tastes promising. The next step is usually drinking it."
    [mana_potion]="You sample the edge of the vial. Definitely magical. Still not as useful as drinking it."
    [potion_of_discipline]="You lick the bottle like you're testing it. The potion somehow feels disappointed in you. Drinking it might improve that."
    [cloth_tunic]="Worn cloth, stale air, and just a hint of body odor."
    [leather_armor]="You taste the leather straps for a moment too long. This has crossed into weird territory."
    [plate_armor]="You drag your tongue across the smooth surface. Slightly oily, definitely not edible."
    [clerk]="You actually try to lick the clerk. She stares at you in stunned silence. \"Absolutely not.\""
)
#!/usr/bin/env bash

stored_look_update() {

#-------------------------
#npc_look
#-------------------------
declare -gA npc_look=(

[clerk_default]="You study the clerk for a moment.

She moves with the kind of practiced efficiency that makes everyone else feel slow. 
Her Cornwall-blue dress is neat despite the endless stacks of parchment, ink, and half-finished forms surrounding her. 
Dark circles sit beneath sharp, focused eyes, the quiet mark of too many late nights and too few breaks.

She rarely looks up for long, her quill already moving before most people finish speaking. 
Even the loudest adventurers lower their voices near her desk.

Whatever keeps this guild standing… it’s probably passed through her hands first." 

)

#-------------------------
#object_look
#-------------------------
declare -gA object_look=(

[fandor_gh_door]="Your eyes drift to the heavy guild doors, thick oak bound with black iron and scarred by years of hard use.

They never seem to stay closed for long. Adventurers come through them covered in mud, blood, gold, or not at all.
A faded guild crest is carved into the center—worn smooth by countless hands pushing their way in...
and, for the lucky ones, back out." 

[fandor_gh_bar]="The guild bar is tucked into the western side of the hall. 
Where torchlight meets smoke and the smell of spilled ale never quite leaves the air.

Scarred mugs, loud laughter, and half-finished stories crowd every inch of it.
More rumors, contracts, and bad decisions have started here than anyone cares to admit."

[fandor_gh_portal]="The swirling ${RED}${BLINK}portal${RESET} hums with unstable energy, crimson ripples
twisting endlessly within the dark oak frame. Faint whispers seep from
its depths, while the air around it feels strangely cold and heavy."

[quest_board]="Weathered parchments cover the quest board, pinned beneath rusted nails
and stained by rain, blood, and ale. Requests for monster hunts, escorts,
missing persons, and dungeon expeditions crowd every inch of wood."

[dummy_1]="A weathered training dummy stands here, covered in scars left by recruits
who were, statistically speaking, ${ITALIC}more promising.${RESET}"


)

}

stored_look_update#!/usr/bin/env bash

#INIT EXTERNAL

source text_effects.sh
source parsers.sh
source navigation.sh
source handlers.sh
source chatarrays.sh
source room_descriptions.sh
source enemies.sh
source spells.sh
source flee.sh
source skills.sh
source dungeon_gen.sh
source character_screen.sh
source lookarrays.sh
source items.sh
source inventory.sh
source quest_board.sh
source dumb_functions.sh
source death_screen.sh
source quest_rewards.sh
clear
wait

#-------------------------
#INIT VARS
#-------------------------

name=""
player_rank="bronze"
class=""
race=""
player_gold=0

location="room_start"
location_tmp="$location"

lvl=1
lvl_points=10
player_xp=0
xp_to_next_lvl=100

strength=0
determination=0
intelligence=0

base_max_health=100
max_health=100
player_health=100

base_max_mana=60
max_mana=60
player_mana=60
mana_recovery=5

base_attack=1
player_attack=0
base_defense=0
player_skill_points=0
max_skill_points=0

player_reputation=50

spawn=true
combat_rank="F"
base_rank="F"

player_skills=("Cleave" "Shadow Step")
player_spells=("Fireball" "Magic Missile")
player_uffs=()
declare -gA has_material=()
declare -gA enemy_kills=()

in_random_dungeon=false
flee_success=false
first_load=true
draw_dungeon=false
set_show_active_quest=true
state="nav"
start_combat=true
char_creation_done=false
prev_state="nav"
bonus_health=0
screen_flashing=true
in_progress_random_dungeon[state]=false

for arg in "$@"; do 
  case "$arg" in
    -sn|--skipn)
      name="Debugger"
      class="warrior"
      race="human"
      char_creation_done="finished"
      location="guild_hall_center"
      first_load=false
      state="nav"
      ;;
    -god|--godmode)
      player_health=9999
      player_mana=9999
      player_skill_points=9999
  esac
done


#-------------------------
#START GAME
#-------------------------

clear
desc_room


#-------------------------
#DISPATCHER
#-------------------------

while true; do

#-------------------------
#NAV STATE
#-------------------------


    while [[ "${state}" == "nav" ]]; do
    story_mode_parser
    done

#-------------------------
#CHAT STATE
#-------------------------


    while [[ "${state}" == "chat" ]]; do
    chat_parser

    done

#-------------------------
#COMBAT STATE
#-------------------------

    while [[ "${state}" == "combat" ]]; do

    if [[ ${start_combat} = true ]]; then
        clear
        combat_start_handler
    fi

    set_enemy_attack
    enemy_display
    comb_tui

    read -r -p "SELECT AN ACTION: " action
    action="${action,,}"
    [[ "${action}" == "r" ]] && [[ ! -z last_action ]] && action="${last_action}"
    last_action="${action}"
    combat_handler
    clear

    done   

#-------------------------
#CHARACTER SCREEN STATE
#-------------------------

while [[ "${state}" == "char_screen" ]]; do
char_screen_tui

done

#-------------------------
#QUEST BOARD SCREEN STATE
#-------------------------

while [[ "${state}" == "using_quest_board" ]]; do
quest_board_handler

done

done#!/usr/bin/env bash

story_navigation () {

   if [[ "${in_random_dungeon}" = false ]]; then
        case $noun:$location in
# GUILD HALL CENTER            
            "east":"guild_hall_center")
                state="using_quest_board"
            ;;
            "south":"guild_hall_center")
                location="fandor_gh_outside"
                desc_room
            ;;
            "west":"guild_hall_center")
                location="fandor_gh_bar"
                desc_room
                ;;
                "east":"fandor_gh_bar")
                    location="guild_hall_center"
                    desc_room
                ;;
                "north":"fandor_gh_bar")
                    echo -e "${WARNING}UNDER CONSTRUCTION!!${RESET}"
                ;;                
            "north":"guild_hall_center")
                verb="talk"
                noun="clerk"
                talk_handler
            ;;
# FANDOR GUILD HALL - OUTSIDE
            "north":"fandor_gh_outside")
                location="guild_hall_center"
                desc_room
            ;;
            "east":"fandor_gh_outside")
                use_portal
            ;;
            "portal":"fandor_gh_outside")
                use_portal
            ;;
            "west":"fandor_gh_outside")
                combat_rank="Z"
                state="combat"
            ;; 
            *guild*:"fandor_gh_outside")
                location="guild_hall_center"
                desc_room
            ;;
            *hall*:"fandor_gh_outside")
                location="guild_hall_center"
                desc_room
            ;;
            *door*:"fandor_gh_outside")
                location="guild_hall_center"
                desc_room
            ;;              
            *)
                echo "You cannot go that way"
            ;;
        esac

    fi
}#!/usr/bin/env bash

story_mode_parser() {
        return_check
        echo -e "\033[?25h" #show cursor if it gets messed up

        noun_array=() #reset noun

        read -r -p "> " input
        input="${input,,}"
        clear
        
            if [[ -z "$input" ]]; then #check if the string is empty
                desc_room
                return
            fi
        
        input=($input) #turn it into an array
        verb="${input[0]}"
        
#verb aliases
        case "$verb" in
            run) verb="go" ;;
            walk) verb="go" ;;
            travel) verb="go" ;;
            head) verb="go" ;;
            traverse) verb="go" ;;
            g) verb="go" ;;
            enter) verb="go" ;;
            n) verb="north" ;;
            s) verb="south" ;;
            e) verb="east"  ;;
            w) verb="west"  ;;
            tl) verb="talk" ;;
            tlk) verb="talk" ;;
            tk) verb="take" ;;
            t) verb="take" ;;
            get) verb="take" ;;
            grab) verb="take" ;;
            pick) verb="take" ;;
            s) verb="start" ;;
            l) verb="look" ;;
            lk) verb="look" ;;
            examine) verb="look" ;;
            see) verb="look" ;;
            investigate) verb="look" ;;
            inspect) verb="look" ;;
            view) verb="look" ;;
            u) verb="use" ;;
            wear) verb="use" ;;
            equip) verb="use" ;;
            don) verb="use" ;;
            wield) verb="use" ;;
            eat) verb="use" ;;
            drink) verb="use" ;;
            lick) verb="taste" ;;
            ex) verb="exit" ;;
        esac


        ignored_words=("at" "the" "it" "to" "in" "on" "with" "from" "into" "inside")

        for (( i=1; i<${#input[@]}; i++));do #loop through input minus verb
            input_iteration="${input[i]}"
            ignore=false

                for c in "${ignored_words[@]}";do #loop through the ignored words
                    if [[ "${input_iteration}" == "${c}" ]];then #ignored words VS i
                        ignore=true
                        break #Stop the loop completely and move on to whatever comes after it
                    fi
                done
                    
                if [[ "$ignore" == false ]];then #add the words that are not ignored -
                    noun_array+=("$input_iteration") #to an array
                fi
        done

        noun="${noun_array[*]}"
#noun aliases
        case "$noun" in
            registration) noun="clerk" ;;
            *clerk*) noun="clerk"  ;;
            n) noun="north" ;;
            s) noun="south" ;;
            w) noun="west" ;;
            e) noun="east" ;;
            "quest board") noun="board";;
            ex) noun="exit" ;;
        esac

                    
    #echo "verb: $verb noun: $noun" #PARSING DEBUGGER

#-------------------------
#VERB PARSING
#-------------------------
if [[ "${first_load}" == true ]]; then #FIRST LOAD PARSING
    case $verb in
        start)
            location="room_reg_tutorial"
            first_load=false
            desc_room
        ;;

        *)
            echo "You typed $input not start silly duck"
            echo
            desc_room
        ;;

    esac
fi

if [[ "${first_load}" == false ]]; then #REGULAR PARSING

    case $verb in

        start)
        :
        ;;

        north|south|east|west)
            noun="$verb"
            go_handler
        ;;

        go)
            go_handler
        ;;

        look)
            look_parsing_handler "$noun"
        ;;

        talk)
            talk_handler
        ;;

        take)
            take_handler
        ;;

        use)
            parse_item_type "$noun"
        ;;

        inventory|i)
            view_inventory
        ;;

        equipment|eq)
            view_equipment
        ;;

        remove|rm)
            remove_equipped_item "$noun"
        ;;

        character|cs)
            prev_state="nav"
            state="char_screen"
        ;;

        taste)
            taste_handler
        ;;
     
        draw)
            if [[ "${draw_dungeon}" == false ]];then
                draw_dungeon=true
                desc_newline
                echo "Draw dungeon on"
            else
                draw_dungeon=false
                desc_newline
                echo "Draw dungeon off"
            fi                  
        ;;
        set_active)
            if [[ "${set_show_active_quest}" == false ]];then
                set_show_active_quest=true
                desc_newline
                echo "Showing active quest on"
            else
                set_show_active_quest=false
                desc_newline
                echo "Showing active quest off"
            fi 
        ;;

        sda)
        for key in ${!player_inventory[@]};do 
        echo "$key ${player_inventory[$key]}"
        done
        ;;
        "exit")
            exit_dungeon_handler
        ;;        

        *)
            desc_newline
            [[ "${in_random_dungeon}" == true ]] && echo
            echo "I'm confused on the whole $verb part"
        ;;

    esac
fi
    [[ "${set_show_active_quest}" == true ]] && show_active_quest

}

#
##
###
####
###########################################################################
####
###
##
#

chat_parser () {
        [[ "${char_creation_done}" == true ]] && clear && echo -e "${fandor_guild[clerk_reg_finished]}"
        noun_array=() #reset noun
            echo
            chatting_prompt="TALKING TO ${who^^}"
            read -r -p "$chatting_prompt > " input

        input="${input,,}"
        clear
        
            if [[ -z "$input" ]]; then #check if the string is empty
                chat_handler
                return
            fi
        
        input=($input) #turn it into an array
        verb="${input[0]}"
        
#verb aliases
        case "$verb" in
            n) verb="north" ;;
        esac


        ignored_words=("at" "the" "it" "to" "in" "on" "with" "from" "into" "inside")

        for (( i=1; i<${#input[@]}; i++));do #loop through input minus verb
            input_iteration="${input[i]}"
            ignore=false

                for c in "${ignored_words[@]}";do #loop through the ignored words
                    if [[ "${input_iteration}" == "${c}" ]];then #ignored words VS i
                        ignore=true
                        break #Stop the loop completely and move on to whatever comes after it
                    fi
                done
                    
                if [[ "$ignore" == false ]];then #add the words that are not ignored -
                    noun_array+=("$input_iteration") #to an array
                fi
        done

        noun="${noun_array[*]}"
#noun aliases
        case "$noun" in
            *clerk*) noun="clerk"  ;;
        esac

                    
    #echo "verb: $verb noun: $noun" #PARSING DEBUGGER

#-------------------------
#VERB PARSING
#-------------------------
    case $verb in

        *bye*|goodbye|gb)
        #hehe ignore this bandaid underneath please
        [[ "${char_creation_done}" == true ]] && char_creation_done="finished" && [[ "${location}" == "room_tutorial_end" ]] && location="guild_hall_center" 
        who=""
        noun=""
        verb=""
        state="nav"
        flee_success=true
        player_health="${max_health}"
        player_mana="${max_mana}"
        player_skill_points="${max_skill_points}"
        return
        ;;

        *)
          chat_handler
        ;;

    esac
}#!/usr/bin/env bash

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

total_enemies_generator(){

for ((i=0; i<3; i++));do
    local -n ref_rank_data="random_quest_${i}_data[rank]"
    local add_array_shit="random_quest_${i}_data[total_enemies]"
    case "${ref_rank_data}" in
        "F") max_enemies_max_min 4 3 "$add_array_shit" ;;
        "E") max_enemies_max_min 6 4 "$add_array_shit" ;;
        "D") max_enemies_max_min 12 8 "$add_array_shit" ;;
        "C") max_enemies_max_min 15 9 "$add_array_shit" ;;
        "B") max_enemies_max_min 20 12 "$add_array_shit" ;;
        "A") max_enemies_max_min 20 15 "$add_array_shit" ;;
        "S") max_enemies_max_min 30 20 "$add_array_shit" ;;
        *) echo "Unknown rank: $ref_rank_data" ;;
    esac
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

    in_progress_random_dungeon[state]=true
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
        total_enemies_generator
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

    echo -e "              ${BOLD}${UNDERLINE}QUEST BOARD${RESET}\n\n"
    echo -e "${UNDERLINE}MINOR QUEST${RESET}\n"
    # echo "it's currently ${current_epoch_seconds} quest will reset at ${base_epoch_seconds}"
    # echo -e "q1 tenem=${random_quest_0_data[total_enemies]} : q2 tenem=${random_quest_1_data[total_enemies]} : q3 tenem=${random_quest_2_data[total_enemies]}"
    echo -e "QUEST [1]    RANK:${random_quest_0_data[rank]}\n${random_quest_0_data[type_display]}${UNDERLINE}${random_quest_0_data[theme_display]} ${RESET}\n"
    echo -e "QUEST [2]    RANK:${random_quest_1_data[rank]}\n${random_quest_1_data[type_display]}${UNDERLINE}${random_quest_1_data[theme_display]} ${RESET}\n"
    echo -e "QUEST [3]    RANK:${random_quest_2_data[rank]}\n${random_quest_2_data[type_display]}${UNDERLINE}${random_quest_2_data[theme_display]} ${RESET}\n"
    echo
    echo "R)echeck"
    echo -e "B)ack\n\n"
    echo -e "Active Quest: RANK:${in_progress_random_dungeon[rank]}\n${in_progress_random_dungeon[type_display]}${UNDERLINE}${in_progress_random_dungeon[theme_display]} ${RESET}\n"
    echo -e "${tutorial[quest_board_how_to]}"
    echo
    read_qb

    case $quest_choice in
        1|2|3) 
        if [[ "${in_progress_random_dungeon[state]}" == false ]]; then
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

}#!/usr/bin/env bash

declare -gA quest_rewards=(

    [f_rank_quest_xp]=15
    [f_rank_quest_gold]=20

    [e_rank_quest_xp]=25
    [e_rank_quest_gold]=30

)#!/usr/bin/env bash

#-------------------------
#MAPFILES
#-------------------------

all_themes=()

for i in rand_dd/*.txt; do

theme="${i##*/}"
theme="${theme%%.*}"

mapfile -t "$theme" < "$i"
all_themes+=("$theme")

done

# printf "%s\n" "${all_themes[@]}"

# declare -n test_ref="ashen_volcano_depths"
# echo "${test_ref[0]}"


#-------------------------
#STORY MODE ROOM DESCRIPTIONS
#-------------------------
declare -gA story_loot=(
    [guild_hall_short_sword]=true
)

build_room_desc(){

if [[ "${story_loot[guild_hall_short_sword]}" == true ]];then
    guild_hall_short_sword="There's a worn looking short sword someone must have left laying around."
else
    unset guild_hall_short_sword
fi

declare -gA room_desc=(

[room_start]="You arrived in Fandor with little more than worn gear and reckless ambition.
In a world where adventurers rise and fall by rank, only the strongest earn
their place among legends.

From lowly guild errands to deadly dungeon contracts, every hunt, victory,
and near-death encounter brings you one step closer to the impossible goal:

${YELLOW}${BOLD}${REVERSE}S-Rank.${RESET}

Few ever reach it. Fewer survive long enough to try.
You push open the heavy wooden doors. Warm light spills out to meet you,
along with the low hum of voices and clinking mugs.

Adventurers crowd long tables—some laughing, some arguing, 
some staring quietly into their drinks.

Steel, leather, and old scars.

${REVERSE}${BOLD}This is the Guild.${RESET}

${DIM}${BLINK}TUTORIAL: Type a command and press enter. 
Type 'start' ${RESET}
"

[room_reg_tutorial]="At the far end of the hall, a worn counter stands beneath a crooked sign:

${REVERSE}REGISTRATION${RESET}

A tired-looking clerk flips through a stack of parchment, 
not bothering to look up. Ink stains their fingers. 

Their patience looks thinner.

${DIM}${BLINK}TUTORIAL: Type the action you would like to achieve:
Type 'talk to the clerk' ${RESET}
"

[room_tutorial_end]="Your commands can be input in a few different ways such as:

${DIM}'talk to the tired looking clerk'
'talk to the clerk'
'talk clerk'
'tl clerk'${RESET}

However if your attempts fail to do something 
always resort back to inputting a verb and noun in its most basic form:

${DIM}'talk clerk'
'go north'
'get lamp'${RESET}

${DIM}${BLINK}TUTORIAL: Type 'talk to clerk' one more time!${RESET}
"

[guild_hall_center]="The heart of the guild hall hums with quiet, constant motion.
Boots scrape across worn wooden floors while low conversations drift 
between tables scarred by years of maps, wagers, and bad decisions. 
The air carries a mix of ale, old parchment, and steel.

At the far end, to the ${BLUE}north${RESET}, a clerk’s desk sits buried 
beneath ledgers that look heavier than most adventurers’ packs,
the woman behind it already busy pretending not to notice you. 

Off to the ${BLUE}west${RESET}, the bar casts a warmer glow, 
voices louder there, laughter coming easier the deeper the mugs get. 

To the ${BLUE}east${RESET}, a crowded quest board bristles with pinned notices, 
edges curled and ink fading, each one quietly promising trouble. 

Behind you, to the ${BLUE}south${RESET}, the heavy doors stand as the only 
real escape—back to open air, and whatever mess you choose to walk into next."

[fandor_gh_bar]="The guild bar is tucked into the western side of the hall. 
Where torchlight meets smoke and the smell of spilled ale never quite leaves the air.

Scarred mugs, loud laughter, and half-finished stories crowd every inch of it.
More rumors, contracts, and bad decisions have started here than anyone cares to admit.

To the ${BLUE}north${RESET} is a board that reads: \"Trophy Kills\". Back to the
${BLUE}east${RESET} is the center of the guild hall."

[fandor_gh_outside]="You are outside of the guild hall onto a stretch of packed earth and worn stone.
To the ${BLUE}north${RESET}, the guild’s heavy doors stand open as adventurers 
come and go beneath its weathered crest.

Off to the ${BLUE}west${RESET}, a battered training dummy waits in the dirt, 
wrapped in fraying rope and scarred by years of practice.

To the ${BLUE}east${RESET}, is a swirling ${RED}portal${RESET}. The ${RED}portal${RESET} is encased in a dark oak frame
casting swirls of crimson ripples.

To the ${BLUE}south${RESET}, the ground opens onto the town’s main road—a busy path 
running west to east through the heart of the settlement, carrying merchants, 
travelers, and more stories than anyone could count. 
${guild_hall_short_sword}"

)
}

build_room_desc
#!/usr/bin/env bash

declare -gA cleave=(

[name]="Cleave"
[damage]="( RANDOM % ((player_attack + 20)) +1 )"
[skill_consumption]="1"
[description]="You deliver a heavy, sweeping strike focused on a single foe, the force of the blow tearing through them with brutal momentum."


)

declare -gA shadow_step=(

[name]="Shadow Step"
[damage]="( RANDOM % player_attack ) + ( RANDOM % player_attack ) + ( RANDOM % player_attack ) + ( RANDOM % player_attack ) + ( RANDOM % player_attack ) + ( RANDOM %  player_attack )"
[skill_consumption]="2"
[description]="You slip through the darkness in a blink, reappearing behind your target to deliver six swift, lethal melee strikes from the shadows."


)

# echo "Spell: ${magic_missile[name]}"
# echo "Damage: ${magic_missile[damage]}"
# echo "Mana Consumed: ${magic_missile[mana_consumption]}"
# echo "${magic_missile[description]}"#!/usr/bin/env bash

declare -gA fireball=(

[name]="Fireball"
[damage]="RANDOM % 16 + 20"
[mana_consumption]=30
[description]="A blazing sphere of arcane fire erupts from your hands and streaks toward your target, exploding on impact in a burst of searing flames."


)

declare -gA magic_missile=(

[name]="Magic Missile"
[damage]="(RANDOM % 14) + (RANDOM % 14) + (RANDOM % 14)"
[mana_consumption]=15
[description]="Three glowing bolts of pure arcane energy dart unerringly from your fingertips, striking their targets with precise, forceful impacts."


)

# echo "Spell: ${magic_missile[name]}"
# echo "Damage: ${magic_missile[damage]}"
# echo "Mana Consumed: ${magic_missile[mana_consumption]}"
# echo "${magic_missile[description]}"#!/usr/bin/env bash

RESET="\e[0m"

# Core effects
BOLD="\e[1m"
DIM="\e[2m"
ITALIC="\e[3m"
UNDERLINE="\e[4m"
BLINK="\e[5m"
REVERSE="\e[7m"
HIDDEN="\e[8m"
STRIKE="\e[9m"

# Foreground colors
BLACK="\e[30m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"

# Bright foreground colors
BRIGHT_BLACK="\e[90m"
BRIGHT_RED="\e[91m"
BRIGHT_GREEN="\e[92m"
BRIGHT_YELLOW="\e[93m"
BRIGHT_BLUE="\e[94m"
BRIGHT_MAGENTA="\e[95m"
BRIGHT_CYAN="\e[96m"
BRIGHT_WHITE="\e[97m"

# Background colors
BG_BLACK="\e[40m"
BG_RED="\e[41m"
BG_GREEN="\e[42m"
BG_YELLOW="\e[43m"
BG_BLUE="\e[44m"
BG_MAGENTA="\e[45m"
BG_CYAN="\e[46m"
BG_WHITE="\e[47m"

# Bright background colors
BG_BRIGHT_BLACK="\e[100m"
BG_BRIGHT_RED="\e[101m"
BG_BRIGHT_GREEN="\e[102m"
BG_BRIGHT_YELLOW="\e[103m"
BG_BRIGHT_BLUE="\e[104m"
BG_BRIGHT_MAGENTA="\e[105m"
BG_BRIGHT_CYAN="\e[106m"
BG_BRIGHT_WHITE="\e[107m"

# Pre-made combos
TITLE="${BOLD}${BRIGHT_CYAN}"
ERROR="${BOLD}${RED}"
SUCCESS="${BOLD}${GREEN}"
WARNING="${BOLD}${YELLOW}${REVERSE}${BLINKING}"
INFO="${CYAN}"

HP_BAR="${BOLD}${RED}"
MANA_BAR="${BOLD}${BLUE}"
GOLD="${BOLD}${YELLOW}"

NPC="${BOLD}${MAGENTA}"
ENEMY="${BOLD}${BRIGHT_RED}"
LOOT="${BOLD}${BRIGHT_YELLOW}"

# Terminal Backgrounds

WHITE_BG=$"\e]11;#FFFFFF\a"
RED_BG=$"\e]11;#550000\a"
GREEN_BG=$"\e]11;#003300\a"
BLACK_BG=$"\e]11;#000000\a"
RESET_BG=$"\e]111\a"

# Make printf happy stupid shit ANSI-C

pf_RESET=$'\e[0m'
pf_BOLD=$'\e[1m'
pf_DIM=$'\e[2m'
pf_ITALIC=$'\e[3m'
pf_UNDERLINE=$'\e[4m'
pf_BLINK=$'\e[5m'
pf_REVERSE=$'\e[7m'
pf_HIDDEN=$'\e[8m'
pf_STRIKE=$'\e[9m'
