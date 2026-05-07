#!/usr/bin/env bash

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