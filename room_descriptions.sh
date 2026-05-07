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
declare -gA story_loot=(
    [guild_hall_short_sword]=true
)

build_room_desc(){

if [[ "${story_loot[guild_hall_short_sword]}" == true ]];then
    guild_hall_short_sword="There's a worn looking short sword someone must have left laying around."
else
    unset guild_hall_short_sword
fi

declare -gA room_desc=(

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

[guild_hall_center]="The heart of the guild hall hums with quiet, constant motion.
Boots scrape across worn wooden floors while low conversations drift between tables scarred by years of maps,
wagers, and bad decisions. The air carries a mix of ale, old parchment, and steel.

At the far end, to the ${BLUE}north${RESET}, a clerk’s desk sits buried beneath ledgers that look heavier than most adventurers’ packs,
the woman behind it already busy pretending not to notice you. Off to the ${BLUE}west${RESET}, the bar casts a warmer glow, 
voices louder there, laughter coming easier the deeper the mugs get. To the ${BLUE}east${RESET}, a crowded quest board bristles with pinned notices, 
edges curled and ink fading, each one quietly promising trouble. Behind you, to the ${BLUE}south${RESET}, the heavy doors stand as the only 
real escape—back to open air, and whatever mess you choose to walk into next."

[fandor_gh_outside]="You are outside of the guild hall onto a stretch of packed earth and worn stone.
To the ${BLUE}north${RESET}, the guild’s heavy doors stand open as adventurers come and go beneath its weathered crest. 
Off to the ${BLUE}west${RESET}, a battered training dummy waits in the dirt, wrapped in fraying rope and scarred by years of practice.

To the ${BLUE}south${RESET}, the ground opens onto the town’s main road—a busy path running west to east through the heart of the settlement, 
carrying merchants, travelers, and more stories than anyone could count. ${guild_hall_short_sword}"

)
}

build_room_desc
