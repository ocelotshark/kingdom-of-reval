#!/usr/bin/env bash

source inventory.sh

    simple_inventory=("${!player_inventory[@]}")
    simple_equipment=("${player_equipment[@]}")

    for i in "${simple_inventory[@]}"; do
        if [[ "$noun" == "$i" ]];then
        echo "found in inventory"
        fi
    done

    for i in "${simple_equipment[@]}"; do
        if [[ "$noun" == "$i" ]];then
        echo "found in eq"
        fi
    done    
    