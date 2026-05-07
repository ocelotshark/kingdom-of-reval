#!/usr/bin/env bash

stored_chat_update() {

#-------------------------
#CHAT
#-------------------------
declare -gA tutorial=(

[character_screen]="After leaving this page you will be viewing your character screen.
The character screen is not only an overview of your stats, and current buffs/debuffs.
It's also how you'll allocate points gained by leveling up to increase your stats.

Here's a quick overview of how stat points work: ${DIM}${BLINK} You can always review these from the game manual. ${RESET}

${BOLD}Determination:${RESET} For every 10 points in determination you'll recieve 1 ${ITALIC}skill${RESET} point added to your maximum skill points.

${BOLD}Strength:${RESET} For every 3 points in stength you'll recieve 1 ${ITALIC}attack${RESET} point added to your maximum attack.

${BOLD}Intelligence:${RESET} For every point in intelligence you'll recieve 3 points of maximum ${ITALIC}mana${RESET}.
"
)
declare -gA fandor_guild=(

[clerk_introduction]="The clerk is wearing a cornwall blue dress that's been well worn. She looks up at you, 
but you feel like she is looking through you as if you are invisible.

Registration, collection, or just here to bother me?
"

[clerk_collection]="I only deal with registered adventurers."

[clerk_class]="She drags a quill across the page without looking up. \"Alright… you wrote down ${name}. That’s something.\"
A pause. She squints at the parchment like it personally offended her.
\"Now I need a class. Try to pick one without wasting both of our time.\"
She finally glances up at you—tired, unimpressed.

\"Go on. What are you?\"


${BOLD}W)arrior${RESET} — Front line. Steel, muscle, and bad decisions. You’ll hit harder the more experienced you get.

${BOLD}C)leric${RESET} — Keep people alive. Or try to. More durable than you look, if you stick with it.

${BOLD}M)age${RESET} — Books, spells, and things catching fire. Your mana pool will grow fast.

${BOLD}P)aladin${RESET} — Bit of everything. Discipline, control… and a tendency to think you’re right.


She taps the page impatiently. \"Well?\"

"
[clerk_race]="She flips to the next page with a sharp flick of her wrist.
\"Race. Try not to make this one complicated.\"
Her eyes scan you quickly, like she’s already made up her mind and just needs it confirmed.

${DIM}Race won't have any effect on gameplay but could lead to some different social interactions.${RESET}


${BOLD}H)uman${RESET} — \"Reliable. Adaptable. Everywhere. You’ll fit in just fine.\"

${BOLD}E)lf${RESET} — \"Graceful, long-lived… and usually aware of it. Try not to look down on everyone.\"

${BOLD}D)warf${RESET} — \"Stubborn, tough, and loud about both. At least you’ll survive.\"

${BOLD}O)rc${RESET} — \"Strong. Direct. People will assume things. They’re not always wrong.\"

${BOLD}Hf)Halfling${RESET} — \"Small, quiet, and underestimated. Probably the smartest way to stay alive, honestly.\"


She taps the quill against the page, once… twice…

\"Well?\"
"

[clerk_reg_finished]="She finishes writing and sets the quill down with a quiet sigh.
\"Alright… that’s you sorted.\"

She looks up for a moment, studying you.

\"Try to keep yourself alive. We lose enough people as it is.\"
A small pause. \"Good luck out there.\"

${DIM}${BLINK}TUTORIAL: Type 'goodbye' to finish interacting with someone.${RESET}
"

[clerk_default]="What do you want ${name}?"

)

}

stored_chat_update