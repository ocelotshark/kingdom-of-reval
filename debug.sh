#!/usr/bin/env bash

fruit=( "banana" "orange" "mango")
veggies=( "broccoli" "spinach" "bittermelon")
feeling=( "happy" "sad" "ecstatic" "depressed" "wet")


name=""
feelingz=""

green_boy() {

veg_index_number=$(( RANDOM % "${#veggies[@]}" ))
veg_index_text="${veggies[$veg_index_number]}"

fruit_index_number=$(( RANDOM % "${#fruit[@]}" ))
fruit_index_text="${fruit[$fruit_index_number]}"

feeling_index_number=$(( RANDOM % "${#feeling[@]}" ))
feeling_index_text="${feeling[$feeling_index_number]}"
feelingz="${feeling_index_text}"

}

hello_pookie(){

the_chosen="$1"

echo "a $the_chosen a day, makes pookie ${feelingz}"

}

green_boy  
hello_pookie "${veg_index_text}"

echo "$feeling_index_number"

