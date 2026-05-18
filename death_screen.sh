#!/usr/bin/env bash

mapfile -t random_e_death < death.txt

#gold loot

random_gold(){
    local max="$1"
    local min="$2"
    
    echo "$(( RANDOM % ($max - $min + 1 ) + $min ))"
}
enemy_loot(){
    case $combat_rank in
    S) local gold_gain="$(random_gold 250 190)" ;;
    A) local gold_gain="$(random_gold 190 100)" ;;
    B) local gold_gain="$(random_gold 100 60)" ;;
    C) local gold_gain="$(random_gold 60 40)" ;;
    D) local gold_gain="$(random_gold 40 22)" ;;
    E) local gold_gain="$(random_gold 22 10)" ;;
    F) local gold_gain="$(random_gold 10 3)" ;;
    Z) local gold_gain=500 ;;
esac

echo "$gold_gain"

}

#update ename

enemy_dead_screen(){
clear

local death="${random_e_death[RANDOM % ${#random_e_death[@]}]}"
local display_death="${death//\$ename/$ename}"

case $combat_rank in
    S) local xp_gain=430 ;;
    A) local xp_gain=360 ;;
    B) local xp_gain=210 ;;
    C) local xp_gain=160 ;;
    D) local xp_gain=60 ;;
    E) local xp_gain=30 ;;
    F) local xp_gain=10 ;;
    Z) local xp_gain=500 ;;
esac

(( player_xp += xp_gain ))
local gold_gain="$(enemy_loot)"
(( player_gold += $gold_gain ))

echo "$display_death"
echo
echo "Through your efforts you gain $xp_gain points of experience"
echo "The $ename drops $gold_gain gold coins"
echo ; echo
echo -e "${REVERSE}EXPERIENCE: $player_xp/$xp_to_next_level GOLD: $player_gold${RESET}"
echo

}
