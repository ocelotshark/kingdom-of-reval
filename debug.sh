#!/usr/bin/env bash

rooms=("1" "2" "3" "4" "5" "6")
bag=20
location=2

declare -A has_material=()

scatter_materials() {
    local loop_bag=$bag
    local room
    local grab

    while (( loop_bag > 0 )); do
        room="${rooms[RANDOM % ${#rooms[@]}]}"

        grab=$(( RANDOM % loop_bag + 1 ))

        (( has_material[$room] += grab ))
        (( loop_bag -= grab ))
    done
}

check_for_material() {

if (( has_material[$location] > 0 ));then
    echo "You see ${has_material[$location]} here"
fi
}

scatter_materials
check_material_for_room


echo -e "\n\n"

for key in "${!has_material[@]}"; do
    echo "$key : ${has_material[$key]}"
done