#!/usr/bin/env bash

declare -gA cleave=(

[name]="Cleave"
[damage]="( RANDOM % player_attack + 20 )"
[skill_consumption]="1"
[description]="You deliver a heavy, sweeping strike focused on a single foe, the force of the blow tearing through them with brutal momentum."


)

declare -gA shadow_step=(

[name]="Shadow Step"
[damage]="( RANDOM % player_attack ) + ( RANDOM % player_attack ) + ( RANDOM % player_attack ) + ( RANDOM % player_attack ) + ( RANDOM % player_attack ) + ( RANDOM %  player_attack )"
[skill_consumption]="2"
[description]="You slip through the darkness in a blink, reappearing behind your target to deliver six swift, lethal melee strikes from the shadows."


)

# echo "Spell: ${magic_missile[name]}"
# echo "Damage: ${magic_missile[damage]}"
# echo "Mana Consumed: ${magic_missile[mana_consumption]}"
# echo "${magic_missile[description]}"