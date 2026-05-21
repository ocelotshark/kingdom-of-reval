#!/usr/bin/env bash

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
        "exit")
            exit_dungeon_handler
        ;;        

        *)
            desc_newline
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

        *bye*|goodbye)
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
}