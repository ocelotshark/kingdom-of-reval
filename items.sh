#!/usr/bin/env bash

declare -gA item_type=(
    [short_sword]="weapon"
    [cloth_tunic]="armor"
    [necklace_of_life]="accessory"
    [necklace_of_mana]="accessory"    
    [apple]="consumable"
    [lever]="object"
    [goblin_ear]="minor_quest_item"
    [troll_toenail]="minor_quest_item"
    [mana_crystal]="minor_quest_item"
    [bottled_tear]="minor_quest_item"
    [whispering_shard]="minor_quest_item"
    [screaming_crystal]="minor_quest_item"
    [gravemoss]="minor_quest_item"
    [witchroot]="minor_quest_item"
    [bloodmint]="minor_quest_item"
    [ceremonial_spoon]="minor_quest_item"
    [ancient_scroll]="minor_quest_item"
    [cracked_idol]="minor_quest_item"
    [ominous_teaspoon]="minor_quest_item"
    [insect_molt]="minor_quest_item"
    [slime_core]="minor_quest_item"
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

declare -gA minor_quest_item_data=(
    [goblin_ear_description]="A shriveled goblin ear, still reeking of damp caves."
    [troll_toenail_description]="A thick troll toenail chipped from some hulking brute."
    [mana_crystal_description]="A glowing crystal humming softly with raw arcane energy."
    [bottled_tear_description]="A tiny glass vial holding a single shimmering tear."
    [whispering_shard_description]="Faint whispers slither from the jagged black shard."
    [screaming_crystal_description]="A crimson crystal that emits distant muffled screams."
    [gravemoss_description]="Cold gray moss gathered from ancient burial stones."
    [witchroot_description]="A twisted root pulsing faintly with unnatural warmth."
    [bloodmint_description]="Dark red mint leaves carrying a sharp metallic scent."
    [ceremonial_spoon_description]="An engraved spoon once used in strange sacred rites."
    [ancient_scroll_description]="A brittle scroll covered in faded forgotten script."
    [cracked_idol_description]="A fractured idol staring ahead with hollow stone eyes."
    [ominous_teaspoon_description]="A tarnished teaspoon radiating quiet unsettling dread."
    [insect_molt_description]="A brittle shell shed by some massive crawling insect."
    [slime_core_description]="A wobbling core of dense slime pulsing with ooze."
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
