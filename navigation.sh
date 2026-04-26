#!/usr/bin/env bash

story_navigation () {

   if [[ "${in_random_dungeon}" = false ]]; then
        case $noun:$location in
            
            "south":"room_start")
                location="room_reg_tutorial"
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