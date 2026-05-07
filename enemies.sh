#!/usr/bin/env bash

#-------------------------
#[ Z ] SPECIAL ENEMIES
#-------------------------

z_rank_spawner() {

declare -gA z_rank_enemies=(

[DUMMY]=9999

)

ename=$1
ehp=${z_rank_enemies[$ename]}

}


#-------------------------
#[ F ] RANK ENEMIES
#-------------------------

f_rank_spawner() {

f_rank_hp_mod=$(( RANDOM % 31 - 10 ))

declare -gA f_rank_enemies=(

[Orc]=$(( 100 + f_rank_hp_mod ))
[Goblin]=$(( 60 + f_rank_hp_mod ))
[Bandit]=$(( 80 + f_rank_hp_mod ))

)

enemy_array=("${!f_rank_enemies[@]}")
random_enemy="${enemy_array[RANDOM % ${#enemy_array[@]}]}"

ename="${random_enemy}"
ehp=${f_rank_enemies[$random_enemy]}

}

#-------------------------
#[ E ] RANK ENEMIES
#-------------------------

e_rank_spawner() {

e_rank_hp_mod=$(( RANDOM % 31 - 10 ))

declare -gA e_rank_enemies=(

[Hobgoblin]=$(( 150 + e_rank_hp_mod ))
[Undead Skeleton]=$(( 100 + e_rank_hp_mod ))
[Shadow]=$(( 110 + e_rank_hp_mod ))

)

enemy_array=("${!e_rank_enemies[@]}")
random_enemy="${enemy_array[RANDOM % ${#enemy_array[@]}]}"

ename="${random_enemy}"
ehp=${e_rank_enemies[$random_enemy]}


}

#-------------------------
#ENEMY NARRATIVES 
#THESE WOULD PROBABLY BE BETTER AS A TEXT FILE OR SOMETHING
#-------------------------

declare -gA hobgoblin_narrative=(

[hobgoblin_0]="The hobgoblin cracks a cruel grin, already certain you will break before it does."
[hobgoblin_1]="A hobgoblin pounds its chest and snarls—discipline and brutality in equal measure."
[hobgoblin_2]="The hobgoblin sneers, sizing you up like you are barely worth the effort."

)

declare -gA undead_skeleton_narrative=(

[undead_skeleton_0]="The skeleton rattles forward, its empty grin promising a very personal haunting."
[undead_skeleton_1]="Bones clatter as it rises—apparently death was not a strong enough hint."
[undead_skeleton_2]="The skeleton tilts its skull at you, as if wondering how you'll look without skin."

)

declare -gA orc_narrative=(

[orc_0]="The orc bares its tusks and laughs—you’re tonight’s entertainment."
[orc_1]="An orc stomps forward, cracking its neck like your bones are next."
[orc_2]="The orc rolls its shoulders and chuckles—you might last a whole two swings."

)

declare -gA goblin_narrative=(

[goblin_0]="The goblin snickers, clutching a rusty blade like it’s already claimed your pockets."
[goblin_1]="A goblin darts in, eyes gleaming—equal parts cowardice and bad intentions."
[goblin_2]="The goblin grins with too many teeth, clearly excited about your misfortune."

)

declare -gA bandit_narrative=(

[bandit_0]="The bandit tips his hat with a smirk—your coin or your blood, he’s not picky."
[bandit_1]="A bandit steps from the shadows, already counting what you’re worth."
[bandit_2]="The bandit chuckles under his breath—easy work always puts him in a good mood."

)

declare -gA shadow_narrative=(

[shadow_0]="The shadow stretches toward you, as if eager to wear your shape next."
[shadow_1]="A shadow slips closer, silent and certain—you’re already halfway gone."
[shadow_2]="The darkness gathers itself into form, and somehow… it’s looking right at you."

)