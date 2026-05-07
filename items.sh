#!/usr/bin/env bash

declare -gA item_type=(
    [short_sword]="weapon"
    [cloth_tunic]="armor"
    [necklace_of_life]="accessory"
    [necklace_of_mana]="accessory"    
    [apple]="consumable"
    [lever]="object"
)

declare -gA weapon_data=(
    [short_sword_damage]=5
    [short_sword_description]="The blade is roughly forged but will get the job done."
    [short_sword_value]=10

)

declare -gA armor_data=(
    [cloth_tunic_defense]=1
    [cloth_tunic_description]="A cheap tunic made of cloth."
    [cloth_tunic_value]=2
    
)

declare -gA accessory_data=(
    [necklace_of_life_modify_variable]="bonus_health"
    [necklace_of_life_modify_value]=10
    [necklace_of_life_description]="A silver necklace with a radiating ruby in the shape of a heart."
    [necklace_of_life_effects]="Raises maximum health by: 10"
    [necklace_of_life_value]=50

    [necklace_of_mana_modify_variable]="bonus_mana"
    [necklace_of_mana_modify_value]=10
    [necklace_of_mana_description]="A gold necklace with a vibrant sapphire in the shape of an orb."
    [necklace_of_mana_effects]="Raises maximum mana by: 10"
    [necklace_of_mana_value]=50
)

declare -gA consumable_data=(
    [apple_modify_variable]="player_health"
    [apple_modify_value]=5
    [apple_description]="Fruit with red or yellow or green skin and sweet to tart crisp whitish flesh."
    [apple_value]=1
)

declare -gA object_data=(
    [lever_description]="A sturdy lever, what does it do? Who knows..."
)

declare -gA taste_data=(
    [short_sword]="You drag your tongue from hilt to tip. Weirdo. It tastes sharply metallic."
    [long_sword]="You give the longer blade an experimental lick. Same sword taste, just more of it."
    [war_axe]="You lean in and give the axe a quick lick. It tastes like violence and poor impulse control."
    [twin_daggers]="You give each dagger a quick taste, as if one might be flavored differently. It is not."
    [sebilles_claymore]="You drag your tongue across the blade. Some relics are meant to inspire awe. 
    Y o u . . . c h o s e . . . t h i s . . ."
    [apple]="You give it a lick. It's an apple, not a mystery."
    [bread]="Your tongue brushes the crust. Crunchy outside, warm inside. Not your worst decision."
    [pie]="You sample the edge of the pie. Sugar, spice, and absolutely no regrets."
    [health_potion]="You lick the bottle like you're unsure of its contents. It tastes promising. The next step is usually drinking it."
    [mana_potion]="You sample the edge of the vial. Definitely magical. Still not as useful as drinking it."
    [potion_of_discipline]="You lick the bottle like you're testing it. The potion somehow feels disappointed in you. Drinking it might improve that."
    [cloth_tunic]="Worn cloth, stale air, and just a hint of body odor."
    [leather_armor]="You taste the leather straps for a moment too long. This has crossed into weird territory."
    [plate_armor]="You drag your tongue across the smooth surface. Slightly oily, definitely not edible."
    [clerk]="You actually try to lick the clerk. She stares at you in stunned silence. \"Absolutely not.\""
)
