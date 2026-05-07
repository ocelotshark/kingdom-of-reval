#!/usr/bin/env bash

#-------------------------
#MAPFILES
#-------------------------

all_themes=()

for i in rand_dd/*.txt; do

theme="${i##*/}"
theme="${theme%%.*}"

mapfile -t "$theme" < "$i"
all_themes+=("$theme")

done

# printf "%s\n" "${all_themes[@]}"

# declare -n test_ref="ashen_volcano_depths"
# echo "${test_ref[0]}"


#-------------------------
#STORY MODE ROOM DESCRIPTIONS
#-------------------------

declare -A room_desc=(

[room_start]="You push open the heavy wooden doors.
Warm light spills out to meet you, along with the low hum of voices and clinking mugs.
Adventurers crowd long tables—some laughing, some arguing, some staring quietly into their drinks.
Steel, leather, and old scars.

${REVERSE}${BOLD}This is the Guild.${RESET}

${DIM}${BLINK}TUTORIAL: Type a command and press enter. 
Type 'start' ${RESET}
"

[room_reg_tutorial]="At the far end of the hall, a worn counter stands beneath a crooked sign:

${REVERSE}REGISTRATION${RESET}

A tired-looking clerk flips through a stack of parchment, not bothering to look up. 
Ink stains their fingers. Their patience looks thinner.

${DIM}${BLINK}TUTORIAL: Type the action you would like to achieve:
Type 'talk to the clerk' ${RESET}
"

[room_tutorial_end]="Your commands can be spoken in a few different ways such as:

${DIM}'talk to the tired looking clerk'
'talk to the clerk'
'talk clerk'
't clerk'${RESET}

However if your attempts fail to do something always resort back to inputting a verb and noun in its most basic form:

${DIM}'talk clerk'
'go north'
'get lamp'${RESET}

Have fun and enjoy yourself in the Kingdom of Reval!

${DIM}${BLINK}TUTORIAL: Type 'talk to clerk' one more time!${RESET}
"

)

