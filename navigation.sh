#!/usr/bin/env bash

story_navigation () {

   if [[ "${in_random_dungeon}" = false ]]; then
        case $noun:$location in
            
            "east":"guild_hall_center")
                echo "you use the quest_board"
            ;;
            "south":"guild_hall_center")
                location="fandor_gh_outside"
                desc_room
            ;;
            "west":"guild_hall_center")
                echo "bar room"
            ;;
            "north":"guild_hall_center")
                echo "clerk shit"
            ;;

            "north":"fandor_gh_outside")
                location="guild_hall_center"
                desc_room
            ;;        

            *)
                echo "You can't go that way"
            ;;
        esac

    fi
}