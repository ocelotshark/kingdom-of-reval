#!/usr/bin/env bash

declare -gA fireball=(

[name]="Fireball"
[damage]="RANDOM % 16 + 20"
[mana_consumption]=30
[description]="A blazing sphere of arcane fire erupts from your hands 
and streaks toward your target, exploding on impact in a burst of 
searing flames."


)

declare -gA magic_missile=(

[name]="Magic Missile"
[damage]="(RANDOM % 14) + (RANDOM % 14) + (RANDOM % 14)"
[mana_consumption]=15
[description]="Three glowing bolts of pure arcane energy dart unerringly 
from your fingertips, striking their targets with precise, forceful impacts."


)

declare -gA burn=(

[name]="Burn"
[damage]="(RANDOM % 7) + (RANDOM % 7) + (RANDOM % 7)"
[mana_consumption]=5
[description]="A jet of crackling flame erupts from your palm, leaving your
enemy singed and wreathed in fading embers."


)

declare -gA drain=(

[name]="Drain"
[damage]="(RANDOM % 5) + (RANDOM % 5) + (RANDOM % 5)"
[special]="drain"
[mana_consumption]=10
[description]="Dark tendrils lash out from your hand, siphoning vitality
from your target and returning a portion of it to you."

)

declare -gA sacrifice=(

[name]="Sacrifice"
[damage]="0"
[special]="hptomana"
[mana_consumption]=0
[description]="Forbidden magic tears vitality from your flesh and forges
it into pure mana, feeding your arcane power."

)

declare -gA pray=(

[name]="Pray"
[damage]="0"
[special]="pray"
[mana_consumption]=1
[description]="You call upon the gods for aid. They have a wicked sense
of humor."

)


# echo "Spell: ${magic_missile[name]}"
# echo "Damage: ${magic_missile[damage]}"
# echo "Mana Consumed: ${magic_missile[mana_consumption]}"
# echo "${magic_missile[description]}"