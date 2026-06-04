#!/usr/bin/env bash

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
                    state="trophy_board"
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
                state="portal_entrance"
            ;;
            "portal":"fandor_gh_outside")
                state="portal_entrance"
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
}