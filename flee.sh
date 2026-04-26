#!/usr/bin/env bash

#-------------------------
#FLEE RANDOM TEXT
#-------------------------

flee=(
$'(your courage falls to the ground)\nYou abandon honor and run!'
$'(you e scape)...\n...but the bards will sing of this cowardice.'
$'The enemy watches you run...\n"Pathetic."'
$'(you begin crying obnoxiously)\nThe enemy is confused, and lets you run away.'
$'(you run away bravely...)\n...in the opposite direction.'
$'(you flee with great speed...)\nand even greater shame.'
$'(your legs fight harder than you did.)\nThey win.'
$'(you retreat!)\nTactically!\nVery, very far away.'
$'(you escape...)\nDignity not included.'
$'(you run like your life depends on it.)\n(It does.)'
$'(you flee.)\nThe enemy is not impressed.'
$'(you make a strategic withdrawal...)\nInto cowardice.'
$'(you run so fast...)\nYou almost look competent.'
$'(you escape, leaving behind your pride...)\nAnd possibly your lunch.'
$'(you flee!)\nEven your shadow refuses to follow.'
$'(you turn tail and sprint...)\nLike a startled chicken.'
$'(you run.)\nThe bards will have a field day with this.'
$'(you escape...)\nAnd immediately regret everything about yourself.'
$'(you flee!)\nSomewhere, a hero shakes their head in disappointment.'
$'(you run screaming into the darkness.)\nBold choice.'
$'(you escape.)\nThe enemy didn’t even bother chasing you.'
$'(you flee!)\nYour ancestors collectively sigh.'
$'(you run like you’ve done this before.)\nThat’s not a good thing.'
$'(you escape!)\nYour reputation does not.'
)

#REMOVE THIS
# flee_state_handler(){
# clear
# rand=$(( RANDOM % ${#flee[@]} ))
# echo -e "${flee[$rand]}"
# echo -e "\n\n"
# read -r -p 'PRESS ANY ENTER TO CONTINUE' 
# state="nav" 
# }