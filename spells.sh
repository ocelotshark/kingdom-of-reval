#!/usr/bin/env bash

declare -gA fireball=(

[name]="Fireball"
[damage]="RANDOM % 16 + 20"
[mana_consumption]=30
[description]="A blazing sphere of arcane fire erupts from your hands and streaks toward your target, exploding on impact in a burst of searing flames."


)

declare -gA magic_missile=(

[name]="Magic Missile"
[damage]="(RANDOM % 14) + (RANDOM % 14) + (RANDOM % 14)"
[mana_consumption]=15
[description]="Three glowing bolts of pure arcane energy dart unerringly from your fingertips, striking their targets with precise, forceful impacts."


)

# echo "Spell: ${magic_missile[name]}"
# echo "Damage: ${magic_missile[damage]}"
# echo "Mana Consumed: ${magic_missile[mana_consumption]}"
# echo "${magic_missile[description]}"