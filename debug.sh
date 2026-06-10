#!/usr/bin/env bash
clear

player_level_array_gen(){
declare -gA player_levels
for ((i=2;i<100;i++));do
    player_levels[$i]=$(( 50 * i * i - 100 ))
done
}

player_level_array_gen

for ((i=2;i<100;i++));do
    echo -e "level:$i - ${player_levels[$i]}\n"
done

