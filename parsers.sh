#!/usr/bin/env bash

story_mode_parser() {
        return_check
        noun_array=() #reset noun

            read -r -p "> " input

        input="${input,,}"
        clear
        
            if [[ -z "$input" ]]; then #check if the string is empty
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
            n) verb="north" ;;
            s) verb="south" ;;
            e) verb="east"  ;;
            w) verb="west"  ;;
            tl) verb="talk" ;;
            tk) verb="take" ;;
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

        gend)
            in_random_dungeon=true
            dungeon_gen 20 10
            #echo "${rooms[*]}"
            loca_index=$(( RANDOM % ${#rooms[@]} ))
            location="${rooms[loca_index]}"
            location_rd_prev="$location"
            desc_room
            
            #echo "CURRENT ROOM=$location"
        ;;       
        combat)
            state="combat"
            
        ;;

        *)
          echo "what?"
          desc_room
        ;;

    esac
fi

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

            read -r -p "talking to $who> " input

        input="${input,,}"
        clear
        
            if [[ -z "$input" ]]; then #check if the string is empty
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

        *bye*|goodbye)
        [[ "${char_creation_done}" == true ]] && char_creation_done="finished" ; location="guild_hall_center" 
        who=""
        noun=""
        verb=""
        state="nav"
        flee_success=true
        return
        ;;

        *)
          chat_handler
        ;;

    esac
}