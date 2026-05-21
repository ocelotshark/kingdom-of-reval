#!/usr/bin/env bash
ename=Orc

declare -gA enemy_kills=()
trophy_kills(){
    (( enemy_kills[$ename]++ ))
}