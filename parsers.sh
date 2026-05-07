#!/usr/bin/env bash

story_mode_parser() {
        return_check
        noun_array=() #reset noun

            read -r -p "> " input

        input="${input,,}"
        clear
        
            if [[ -z "$input" ]]; then #check if the string is empty
                continue
            fi
        
        input=($input) #turn it into an array
        verb="${input[0]}"
        
#verb aliases
        case "$verb" in
            n) verb="north" ;;
            s) verb="south" ;;
            e) verb="east"  ;;
            w) verb="west"  ;;
            t) verb="talk" ;;
            s) verb="start" ;;
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
        esac

                    
    #echo "verb: $verb noun: $noun" #PARSING DEBUGGER

#-------------------------
#VERB PARSING
#-------------------------
if [[ "${first_load}" == true ]]; then
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

if [[ "${first_load}" == false ]]; then

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
            look_handler
        ;;

        talk)
            talk_handler
        ;;

        gend)
            in_random_dungeon=true
            dungeon_gen 6 4
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
        ;;

    esac
fi

}

chat_parser () {

        return_check
        noun_array=() #reset noun

            read -r -p "> " input

        input="${input,,}"
        clear
        
            if [[ -z "$input" ]]; then #check if the string is empty
                continue
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
            registration) noun="clerk" ;;
            *clerk*) noun="clerk"  ;;
        esac

                    
    #echo "verb: $verb noun: $noun" #PARSING DEBUGGER

#-------------------------
#VERB PARSING
#-------------------------
    case $verb in

        registration)
            chat_handler
        ;;

        no)
            chat_handler
        ;;  

        *)
          echo "what?"
        ;;

    esac
}