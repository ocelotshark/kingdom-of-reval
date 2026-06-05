#!/usr/bin/env bash

declare -gA item_type=(
    [short_sword]="weapon"
    [stick]="weapon"
    [cloth_tunic]="armor"
    [necklace_of_life]="accessory"
    [necklace_of_mana]="accessory"    
    [apple]="consumable"
    [stale_bread]="consumable"
    [ale]="consumable"
    [minor_health_potion]="consumable"
    [minor_mana_potion]="consumable"
    [ironwill_stout]="consumable"
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
declare -gA item_value=(
    [short_sword_value]=10
    [stick_value]=0
    [cloth_tunic_value]=2
    [necklace_of_life_value]=50
    [necklace_of_mana_value]=50
    [apple_value]=3
    [stale_bread_value]=3
    [ale_value]=2
    [minor_health_potion_value]=15
    [minor_mana_potion_value]=15
    [ironwill_stout_value]=40
)
declare -gA weapon_data=(
    [short_sword_damage]=5
    [short_sword_description]="The blade is roughly forged but will get the job done."
    [short_sword_value]=10

    [stick_damage]=1
    [stick_description]="There's many like it, but this on is yours."
    [stick_value]=0

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
    [apple_value]=3

    [stale_bread_modify_variable]="player_health"
    [stale_bread_modify_value]=5
    [stale_bread_description]="A brick disguised as bread. Surprisingly edible."
    [stale_bread_value]=3

    [ale_modify_variable]="player_health"
    [ale_modify_value]=3
    [ale_description]="Cheap ale strong enough to make bad sound good, and ugly look pretty."
    [ale_value]=2

    [minor_health_potion_modify_variable]="player_health"
    [minor_health_potion_modify_value]=25
    [minor_health_potion_description]="A tiny vial of red liquid prized by adventurers with shallow pockets."
    [minor_health_potion_value]=15

    [minor_mana_potion_modify_variable]="player_mana"
    [minor_mana_potion_modify_value]=25
    [minor_mana_potion_description]="A common potion used by novice mages who burn through mana too quickly"
    [minor_mana_potion_value]=15

    [ironwill_stout_modify_variable]="player_skill_points"
    [ironwill_stout_modify_value]=1
    [ironwill_stout_description]="Strong enough to make your chest burn and your instincts wake back up."
    [ironwill_stout_value]=40
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
    [stick]="You give the stick a good lick and end up with so many splinters."
    [long_sword]="You give the longer blade an experimental lick. 
Same sword taste, just more of it."
    [war_axe]="You lean in and give the axe a quick lick. 
It tastes like violence and poor impulse control."
    [twin_daggers]="You give each dagger a quick taste, 
as if one might be flavored differently. It is not."
    [sebilles_claymore]="You drag your tongue across the blade. 
Some relics are meant to inspire awe. 
Y o u . . . c h o s e . . . t h i s . . ."
    [apple]="You give it a lick. It's an apple, not a mystery."
    [bread]="Your tongue brushes the crust. 
Crunchy outside, warm inside. Not your worst decision."
    [pie]="You sample the edge of the pie. 
Sugar, spice, and absolutely no regrets."
    [health_potion]="You lick the bottle like you're unsure of its contents. 
It tastes promising. The next step is usually drinking it."
    [mana_potion]="You sample the edge of the vial. Definitely magical. 
Still not as useful as drinking it."
    [potion_of_discipline]="You lick the bottle like you're testing it. 
The potion somehow feels disappointed in you. Drinking it might improve that."
    [cloth_tunic]="Worn cloth, stale air, and just a hint of body odor."
    [leather_armor]="You taste the leather straps for a moment too long. 
This has crossed into weird territory."
    [plate_armor]="You drag your tongue across the smooth surface. 
Slightly oily, definitely not edible."
    [clerk]="You actually try to lick the clerk. 
She stares at you in stunned silence. \"Absolutely not.\""
    [trophy_board]="The wood is dry and bitter, with a hint of stale beer."
    [bar_drink]="You grab an abandoned drink and take a bold swig.
Thick tobacco spit coats your tongue."
    [bar_counter]="You place your tongue against the counter.
The wood is sticky.
That single fact tells you everything you needed to know."
    [bartender_taste]="You attempt to taste the bartender, but the counter is too wide.
Instead, you awkwardly stick your tongue out in his direction."

)

declare -gA talk_object=(
    [bar]="${ITALIC}\"How's it going?\"${RESET} you ask the wooden bar.
You get no response. Multiple patrons distance themselves from you."
)

declare -gA generic_taste_data=(
    [floor_taste_0]="You lick the floor.
A thick layer of greasy grime slides across your tongue like cold fat."
    [floor_taste_1]="You press your tongue to the ground.
Something wet pops beneath it."
    [floor_taste_2]="You drag your tongue across the filthy floorboards.
The taste of mildew, spit, and spoiled meat floods your mouth."
    [floor_taste_3]="You give the floor a curious lick.
A wad of something half-dried sticks briefly to your tongue."
    [floor_taste_4]="You kneel down and taste the ground.
Warm slime clings stringily to your lips as you pull away."
    [floor_taste_5]="You lick a dark stain on the floor.
The sour taste instantly makes your stomach tighten in warning."
    [floor_taste_6]="You boldly lick the floorboards.
Tiny grains, loose hairs, and greasy dirt crunch in your teeth."
    [floor_taste_7]="You place your tongue against the damp floor.
The flavor resembles spoiled broth left out in summer heat."
    [floor_taste_8]="You run your tongue along the filthy ground.
Something rancid bursts across your taste buds with horrifying force."
    [floor_taste_9]="You sample the floor with a long lick.
The texture is thick, sticky, and far warmer than it should be."
    [wall_taste_0]="You lick the wall.
A layer of damp grime peels across your tongue in oily streaks."
    [wall_taste_1]="You press your tongue against the wall.
The surface tastes like mold soaked in old smoke."
    [wall_taste_2]="You drag your tongue slowly along the wall.
Something crusted flakes loose into your mouth."
    [wall_taste_3]="You cautiously lick the stained wall.
A bitter taste of mildew and rotten moisture fills your throat."
    [wall_taste_4]="You give the wall an experimental lick.
The texture resembles wet cloth left to decay in a cellar."
    [wall_taste_5]="You run your tongue across the damp surface.
Warm slime stretches briefly before snapping back onto the wall."
    [wall_taste_6]="You boldly taste the wall.
Dust, grease, and something sour grind unpleasantly in your teeth."
    [wall_taste_7]="You lick a dark patch on the wall.
The foul taste instantly makes your eyes water."
    [wall_taste_8]="You place your tongue against the cracked stone.
Something gritty and damp shifts beneath the surface."
    [wall_taste_9]="You slowly lick the filthy wall.
The flavor resembles a rotting corpse."
)
