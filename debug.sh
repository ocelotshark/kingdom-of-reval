#!/usr/bin/env bash

save_handler(){
    read -p -r "FILE SAVE NAME > " file_name
    file_name="${file_name,,}"
    file_name="${file_name// /_}"

    save_game_data=(
        location
        prev_location
        name
        player_rank
        class
        race
        player_gold
        lvl
        lvl_points
        player_xp
        strength
        determination
        intelligence
        base_max_health
        max_health
        player_health
        base_max_mana
        max_mana
        player_mana
        mana_recovery
        base_attack
        player_attack
        base_defense
        player_skill_points
        base_skill_points
        max_skill_points
        player_reputation
        base_rank
        player_skills
        player_spells
        player_equipment
        player_inventory
        enemy_kills
        enemies_killed_stat
        chat_states
    )

    for i in "${save_game_data[@]}"; do
        declare -p "$i" >> "$file_name"
    done

}