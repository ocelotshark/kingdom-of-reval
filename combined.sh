===== combined.sh =====


===== dungeon_gen.sh =====
#!/usr/bin/env bash

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

declare -A random_dungeon_properties

rand_theme_and_fill() {

    selected_theme_idx=$(( RANDOM % ${#all_themes[@]} ))
    selected_theme="${all_themes[$selected_theme_idx]}"
    declare -n current_theme="$selected_theme"

    already_used=()

    for (( i=0; i<${#rooms[@]}; i++ )); do
        
        room="${rooms[i]}"

        while :; do
            tmp_desc_pick_idx=$(( RANDOM % ${#current_theme[@]} ))

            used=false
            for u in "${already_used[@]}"; do
                if [[ "$u" == "$tmp_desc_pick_idx" ]]; then
                    used=true
                    break
                fi
            done

            if [[ $used == false ]]; then
                already_used+=("$tmp_desc_pick_idx")

                tmp_desc_pick="${current_theme[$tmp_desc_pick_idx]}"
                description_key="${room},description"

                random_dungeon_properties["$description_key"]="$tmp_desc_pick"
                break
            fi
        done
                
    done

}
#-------------------------
#EXEC
#-------------------------

random_dungeon_init
candidate_lottery
rand_theme_and_fill

}


===== enemies.sh =====
#!/usr/bin/env bash

#-------------------------
#[ F ] RANK ENEMIES
#-------------------------

f_rank_spawner() {

f_rank_hp_mod=$(( RANDOM % 31 - 10 ))

declare -gA f_rank_enemies=(

[Orc]=$(( 100 + f_rank_hp_mod ))
[Goblin]=$(( 60 + f_rank_hp_mod ))
[Bandit]=$(( 80 + f_rank_hp_mod ))

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

e_rank_hp_mod=$(( RANDOM % 31 - 10 ))

declare -gA e_rank_enemies=(

[Hobgoblin]=$(( 150 + e_rank_hp_mod ))
[Undead Skeleton]=$(( 100 + e_rank_hp_mod ))
[Shadow]=$(( 110 + e_rank_hp_mod ))

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

)
===== flee.sh =====
#!/usr/bin/env bash

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
# }
===== handlers.sh =====
#!/usr/bin/env bash

#-------------------------
#DESCRIBE ROOM
#-------------------------

desc_room() {
    [[ ${in_random_dungeon} == false ]] && echo "${room_desc[$location]}"
    [[ ${in_random_dungeon} == true ]] && echo "${random_dungeon_properties["$location,description"]}"
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
#GO VERB HANDLER
#-------------------------

go_handler() {
    if [[ "${in_random_dungeon}" = true ]]; then
        case $noun in
            
            "north")
                rdung_nav_checker_north
                echo "location: $location"
                draw_dungeon
                                
            ;;

            "south")
                rdung_nav_checker_south
                echo "location: $location"
                draw_dungeon
                
            ;;

            "west")
                rdung_nav_checker_west
                echo "location: $location"
                draw_dungeon
                
            ;;

            "east")
                rdung_nav_checker_east
                echo "location: $location"
                draw_dungeon
                
            ;;

            *)
                echo "You can't go that way"
            ;;

        esac
    fi

    if [[ "${in_random_dungeon}" = false ]]; then
        case $noun:$location in
            
            "north":"room0")
                location="room1"
                desc_room
            ;;

            "south":"room1")
                location="room0"
                desc_room
            ;;

            *)
                echo "You can't go that way"
            ;;
        esac
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

        "pool":"room1")
            echo "The water is disgusting"
        ;;

        *)
            if [[ -n "${noun}" ]]; then #if its an unknown noun
                echo "You don't see $noun"
            fi

    esac      
}

    action1="placeholder1"
    action2="placeholder2"

#-------------------------
#COMBAT INTRODUCTION HANDLER
#-------------------------

intro_handler() {

    if [[ $combat_start == true ]]; then
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
}

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

desc_enemy() {

    case $combat_rank in
#EATTACK_RANGES
        F)
        eattack=$(( RANDOM % 10 + 1 ))
        ;;

        E)
        eattack=$(( RANDOM % 20 + 1 ))
        ;;

    esac 

    if [[ $action == "" ]];then
            combat_start=true
        else
            combat_start=false
    fi

        echo "$ename     Health: $ehp"     #EATTACK_DEBUG: $eattack"
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
                if [[ $turn == true ]];then
                    local attackdamage=$(( RANDOM % 3 + 0 + $player_attack ))
                    ehp=$((ehp - attackdamage))
                    action1="You hit the $ename for $attackdamage pts!"
                    player_health=$(( player_health - eattack ))
                    action2="$ename hits you for $eattack"

                fi
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
===== main.sh =====
#!/usr/bin/env bash

#INIT EXTERNAL

source handlers.sh
source room_descriptions.sh
source enemies.sh
source spells.sh
source flee.sh
source skills.sh
source dungeon_gen.sh

#-------------------------
#INIT VARS
#-------------------------

name="Wesley"
location="room0"
location_tmp="$location"

max_health=100
player_health=100

max_mana=100
player_mana=100
mana_recovery=5

player_attack=5
player_defense=1
player_skill_points=6
spawn=true

player_skills=("Cleave" "Shadow Step")
player_spells=("Fireball" "Magic Missile")
in_random_dungeon=false

#-------------------------
#STATE NAVIGATION
#-------------------------

state="nav"


while true; do

#-------------------------
#NAV STATE
#-------------------------

    while [[ "${state}" == "nav" ]];do
        noun_array=() #reset noun

        read -r -p "> " input
        input="${input,,}"
        clear
        
            if [[ -z "$input" ]]; then #check if the string is empty
                continue
            fi
        
        input=($input) #turn it into an array
        verb="${input[0]}"

        case "$verb" in
            n) verb="north" ;;
            s) verb="south" ;;
            e) verb="east"  ;;
            w) verb="west"  ;;
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
                    
    #echo "verb: $verb noun: $noun" #PARSING DEBUGGER

#-------------------------
#VERB PARSING
#-------------------------

    case $verb in
        north|south|east|west)
            noun="$verb"
            go_handler
        ;;
        go)
            go_handler
        ;;

        look)
            look_handler
        ;;

        gend)
            in_random_dungeon=true
            dungeon_gen 6 4
            echo "${rooms[*]}"
            loca_index=$(( RANDOM % ${#rooms[@]} ))
            location="${rooms[loca_index]}"
            echo "CURRENT ROOM=$location"
        ;;
#temp code to enter random dungeon
        f) 
        if [[ "${in_random_dungeon}" == true ]]; then
            echo "Are you sure you want to exit the dungeon?"
            read -r -p "Y)es or N)o" confirm

            case $confirm in
                y|yes)
                    location="$location_tmp"
                    in_random_dungeon=false
                ;;    
                n|no)
                    :
                ;;
            esac
        else 
            echo "this function only debugs leaving a dungeon"
        fi

        ;;        
#temp code to enter random combat        
        combat)
            state="combat"
            
        ;;

        *)
          echo "what?"
        ;;

    esac

    done

#-------------------------
#COMBAT STATE
#-------------------------

    while [[ "${state}" == "combat" ]]; do
        clear
        combat_rank="E"
        turn=true
        
        # if [[ $turn ]]; then;
        #     turn=flase
        # else
        #     turn=true
        # fi

#-------------------------
#RANK HANDLER
#-------------------------

    if [[ $spawn == true ]]; then

        case $combat_rank in
            E)
                e_rank_spawner
                spawn=false
            ;;

            F)
                f_rank_spawner
                spawn=false
            ;;
            
        esac
    fi
#-------------------------
#COMBAT EXECTUTION
#-------------------------

        desc_enemy
        intro_handler
        comb_tui

        read -r -p "SELECT AN ACTION: " action
        action="${action,,}"

        combat_handler
    done
done
===== room_descriptions.sh =====
#!/usr/bin/env bash

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

#printf "%s\n" "${all_themes[@]}"


#-------------------------
#STORY MODE ROOM DESCRIPTIONS
#-------------------------

declare -A room_desc=(

[room0]="This is room0 its pretty bare."
[room1]="This is room1 it has a pool."

)


===== skills.sh =====
#!/usr/bin/env bash

declare -gA cleave=(

[name]="Cleave"
[damage]="( RANDOM % player_attack + 20 )"
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
# echo "${magic_missile[description]}"
===== spells.sh =====
#!/usr/bin/env bash

player_spells=("Fireball" "Magic Missile")

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
# echo "${magic_missile[description]}"
