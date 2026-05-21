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
}  