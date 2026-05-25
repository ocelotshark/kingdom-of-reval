#!/usr/bin/env bash
source text_effects.sh
source items.sh

state="shopping"
vendor="fandor_recruit_market"
buying=false
player_gold=100

declare -gA player_inventory=(
    [cloth_tunic]=1
    [necklace_of_life]=1
    [necklace_of_mana]=1
    [apple]=26
)

declare -gA fandor_recruit_market=(
    [apple]=3
    [banana]=3
    [coconut]=6
)

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
            printf "%-20s %5s\n" "${key^}" "${current_vendor[$key]}"
        done

        echo -e "${UNDERLINE}                      ${RESET}\n"
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
    input="${input,,}"

    case $input in
        p|purchase)
            if [[ "${buying}" == false ]];then #toggle menu
                buying=true ; return
            else
                read -r -p "Purchase what? " input #prompt for buying
                input="${input,,}"
                input="${input// /_}"

                if [[ -n "${current_vendor[$input]}" ]];then #valid item for this shop?
                    if (( (player_gold - current_vendor[$input]) >= 0 ));then #enough money?
                        (( player_gold -= current_vendor[$input] ))
                        echo "ADDED"
                        read
                    else
                        echo "YOU DONT HAVE THE MONEY FOR THAT"
                        read
                    fi
                else
                    echo "ITEM DOES NOT EXIST"
                    read
                fi
            fi          
        ;;
        s|sell)
            if [[ "${buying}" == true ]];then #toggle menu
                buying=false ; return
            else
                read -r -p "Sell what? " input #prompt for buying
                input="${input,,}"
                input="${input// /_}"

                if [[ -n "${player_inventory[$input]}" ]];then #valid item for this shop?
                    if (( player_inventory[$input] > 1 )); then
                        read -r -p "How many would you like to sell: " amount
                        if [[ "$amount" -eq "$amount" ]] 2>/dev/null; then
                            if (( $amount <= player_inventory[$input] ));then
                                for ((i=0;i<amount;i++));do
                                    echo "$i REMOVED"
                                    (( player_gold += item_value[${input}_value] ))
                                done
                                read
                                return
                            else
                                echo "You don't own that many to sell!"
                                read
                                return
                            fi
                        else
                            echo "If you can't tell me a number, I can't help you..."
                            read
                            return
                        fi
                    else
                        (( player_gold += item_value[${input}_value] ))
                        echo "REMOVED"
                        read
                    fi

                else
                    echo "ITEM DOES NOT EXIST"
                    read
                fi
            fi  

        ;;
        h|help)
        :
        ;;
        b|back)
            exit
        ;;
        *)
            echo "Invalid Command"
            read
        ;;
    esac

}

while [[ "${state}" == "shopping" ]]; do
    shopping_parser
done

