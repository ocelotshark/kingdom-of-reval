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

        rescue)
            rescue_handler
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

        shs)
        printf '%b\n' "${max_health}"
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
        if [[ "${char_creation_done}" == true ]] && char_creation_done="finished" && [[ "${location}" == "room_tutorial_end" ]];then
            location="guild_hall_center" 
            player_health="${max_health}"
            player_mana="${max_mana}"
            player_skill_points="${max_skill_points}"
        fi
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

shopping_parser(){
    local -n current_vendor="${vendor}"
    local item_header="${BOLD}${UNDERLINE}ITEM${RESET}"
    local prices_header="${BOLD}${UNDERLINE}VALUE${RESET}"
    local header_quantity="${BOLD}${UNDERLINE}OWNED${RESET}"
    local input
    local amount


    clear

    if [[ "${buying}" == true ]];then
        echo -e "${BOLD}${UNDERLINE}BUYING${RESET}\n"
        printf "%-32b %b\n" "${item_header}" "${prices_header}"
        for key in "${!current_vendor[@]}";do
            local display_key="${key//_/ }"
            printf "%-20s %5s\n" "${display_key^}" "${current_vendor[$key]}"
        done

        echo -e "${UNDERLINE}                         ${RESET}\n"
        echo "P)urchase"
        echo "S)ell Menu"
        echo "H)elp"        
        echo
        echo "B)ack"
        echo
        echo -e "${REVERSE}COIN POUCH:$player_gold${RESET}"
        echo
    else
        echo -e "${BOLD}${UNDERLINE}SELLING${RESET}\n"
        printf "%-32b %b %b\n" "${item_header}" "${header_quantity}" "${prices_header}"
        for key in "${!player_inventory[@]}";do
            local display_key="${key//_/ }"
            display_key="${display_key^}"
            printf "%-20s x %3s %5s\n" "$display_key" "${player_inventory[$key]}" "${item_value[${key}_value]}"
        done

        echo -e "${UNDERLINE}                                ${RESET}\n"
        echo "P)urchase Menu"
        echo "S)ell"
        echo "H)elp"
        echo
        echo "B)ack"       
        echo
        echo -e "${REVERSE}COIN POUCH:$player_gold${RESET}"
        echo        
    fi

    read -r -p "> " input
    [[ -z "${input}" ]] && return
    input="${input,,}"

    case $input in
        p|purchase)
            if [[ "${buying}" == false ]];then #toggle menu
                buying=true ; return
            else
                read -r -p "Purchase what? " input #prompt for buying
                [[ -z "${input}" ]] && return
                local disp_input="${input}"
                input="${input,,}"
                input="${input// /_}"

                if [[ -n "${current_vendor[$input]}" ]];then #valid item for this shop?
                    if (( (player_gold - current_vendor[$input]) >= 0 ));then #enough money?
                        (( player_gold -= current_vendor[$input] ))
                        add_item_handler "$input"
                        echo -e "${ITALIC}${disp_input^} added to inventory.${RESET}"
                        press_any_to_continue
                    else
                        echo "You don't have enough money for that."
                        press_any_to_continue
                        return
                    fi
                else
                    echo "\"I don't have ${input//_/ }\""
                    press_any_to_continue
                    return
                fi
            fi          
        ;;
        s|sell)
            if [[ "${buying}" == true ]];then #toggle menu
                buying=false ; return
            else
                read -r -p "Sell what? " input #prompt for buying
                [[ -z "${input}" ]] && return
                input="${input,,}"
                input="${input// /_}"

                if [[ -n "${player_inventory[$input]}" ]];then #valid item for this shop?
                    if (( player_inventory[$input] > 1 )); then
                        read -r -p "How many would you like to sell: " amount
                        if [[ "$amount" -eq "$amount" ]] 2>/dev/null; then
                            if (( $amount <= player_inventory[$input] ));then
                                for ((i=0;i<amount;i++));do
                                    remove_item_handler "$input"
                                    (( player_gold += item_value[${input}_value] ))
                                done
                                return
                            else
                                echo "You don't own that many to sell!"
                                press_any_to_continue
                                return
                            fi
                        else
                            echo "If you can't tell me a number, I can't help you..."
                            press_any_to_continue
                            return
                        fi
                    else
                        (( player_gold += item_value[${input}_value] ))
                        remove_item_handler "$input"
                        return
                    fi

                else
                    echo "You try to scam the seller and sell them air, you fail."
                    press_any_to_continue
                fi
            fi  

        ;;
        h|help)
        :
        ;;
        b|back)
            clear
            flee_success=true
            vendor=""
            state="${prev_state}"
        ;;
        *)
            echo "Invalid Command"
            read
        ;;
    esac

}