#!/usr/bin/env bash

declare -gA chat_states=(
    [fandor_bartender]=0
)

waiting_chat(){
printf '\e[?25l'
for (( i=0; i<3; i++ )); do
    printf "."
    sleep 0.7
done
echo
printf '\e[?25h'
}
stored_chat_update() {

#-------------------------
#CHAT
#-------------------------
declare -gA tutorial=(

[character_screen]="After leaving this page you will be viewing your character screen.
The character screen is not only an overview of your stats, 
and current buffs/debuffs.

It's also how you'll allocate points gained 
by leveling up to increase your stats.

Here's a quick overview of how stat points work: 
${DIM}${BLINK} You can always review these from the game manual. ${RESET}

${BOLD}Determination:${RESET} For every 10 points in determination 
you'll receive 1 ${ITALIC}skill${RESET} point added to your maximum skill points.

${BOLD}Strength:${RESET} For every 3 points in stength 
you'll receive 1 ${ITALIC}attack${RESET} point added to your maximum attack.

${BOLD}Intelligence:${RESET} For every point in intelligence 
you'll receive 3 points of maximum ${ITALIC}mana${RESET}.
"
[quest_board_how_to]="${DIM}NEW ADVENTURERS READ: ONLY ONE MINOR QUEST CAN BE HELD AT A TIME
MINOR QUEST CAN BE ACCESSED THROUGH A GUILD PORTAL
COMPLETED QUEST SHOULD BE TURNED INTO THE GUILD CLERK${RESET}"
)
declare -gA fandor_guild=(

[clerk_introduction]="The clerk is wearing a cornwall blue dress that's been well worn. 
She looks up at you, but you feel like she is looking through you as 
if you are invisible.

${BLINK}Registration${RESET}, ${BLINK}collection${RESET}, or just here to ${BLINK}bother${RESET} me?
"

[clerk_collection]="I only deal with registered adventurers."

[clerk_class]="She drags a quill across the page without looking up. 
\"Alright… you wrote down ${name}. That’s something.\"

A pause. She squints at the parchment like it personally offended her.

\"Now I need a class. Try to pick one without wasting both of our time.\"
She finally glances up at you—tired, unimpressed.

\"Go on. What are you?\"


${BnR}W)arrior${RESET} — Front line. Steel, muscle, and bad decisions. 
You’ll hit harder the more experienced you get.

${BnR}C)leric${RESET} — Keep people alive. Or try to. 
More durable than you look, if you stick with it.

${BnR}M)age${RESET} — Books, spells, and things catching fire. 
Your mana pool will grow fast.

${BnR}P)aladin${RESET} — Bit of everything. Discipline, control… 
and a tendency to think you’re right.


She taps the page impatiently. \"Well?\"

"
[clerk_race]="She flips to the next page with a sharp flick of her wrist.
\"Race. Try not to make this one complicated.\"
Her eyes scan you quickly, like she’s already made up her mind 
and just needs it confirmed.

${DIM}Race won't have any effect on gameplay 
but could lead to some different social interactions.${RESET}


${BnR}H)uman${RESET} — \"Reliable. Adaptable. Everywhere. 
You’ll fit in just fine.\"

${BnR}E)lf${RESET} — \"Graceful, long-lived… and usually aware of it. 
Try not to look down on everyone.\"

${BnR}D)warf${RESET} — \"Stubborn, tough, and loud about both. 
At least you’ll survive.\"

${BnR}O)rc${RESET} — \"Strong. Direct. People will assume things. 
They’re not always wrong.\"

${BnR}Hf)Halfling${RESET} — \"Small, quiet, and underestimated. 
Probably the smartest way to stay alive, honestly.\"


She taps the quill against the page, once… twice…

\"Well?\"
"

[clerk_reg_finished]="She finishes writing and sets the quill down with a quiet sigh.
\"Alright… that’s you sorted.\"

She looks up for a moment, studying you.

\"Try to keep yourself alive. We lose enough people as it is.\"
A small pause. \"Good luck out there.\"

${DIM}${BLINK}TUTORIAL: While chatting it's best to just input a single keyword.
Type 'goodbye' to finish interacting with someone.${RESET}"
#01clerk chatting

[clerk_default_1]="The clerk barely looks up from the papers scattered across the counter.
${RESET}\"What do you want, ${name}?\"${RESET}"

[clerk_default_2]="She flips through a ledger with practiced impatience.
${RESET}\"If you're here for work, ask about questing. 
If you've finished something, collect your reward and move along.\"${RESET}"

[clerk_collect_success_neutral]="The clerk reviews your papers, then gives a small nod.
\"Looks legitimate enough.\"

She reaches beneath the counter and returns with your payment.
\"Keep them coming.\" The clerk hands you:"

[clerk_collect_success_rescue]="The clerk scans over the rescue report, then glances up at the
exhausted survivor beside you.

\"Still breathing. That's better than most.\" She scribbles a few
notes onto the parchment before reaching beneath the counter.

\"Good work out there.\" The clerk hands you:"

[clerk_collect_success_materials]="The clerk inspects the bundled materials one by one, carefully
counting each piece before giving a satisfied nod.

\"Everything's here. Nicely done.\" She pulls a reward pouch from
beneath the counter and slides it toward you.

\"The guild will make good use of these.\" The clerk hands you:"

[clerk_collect_failure_neutral]="The clerk glances over your records before sliding them back.
\"Nothing completed.\"

She dips her quill into ink and resumes writing.
\"Come back when you've actually finished something, ${name}.\""

#01training dummy chatting

[dummy_default_1]="You attempt conversation with the dummy.
Several nearby adventurers pretend not to notice."

[dummy_default_2]="You try speaking to the dummy.
A passing recruit quietly picks up their pace."

[dummy_default_3]="You attempt to converse with the dummy.
This explains a lot, honestly."

[dummy_default_4]="You ask the training dummy a question.
The dummy's silence feels judgmental."

#01bartender

[bartender_firstmeeting]="\"New around here, are we?\"

He sets aside a freshly cleaned mug and looks up at you.

\"Name's Durgin Stonebeard. I run the bar around here, and keep the riff-raff
in line when I have to. I sell a few adventuring supplies, brew a decent drink,
and I don't mind sharing a bit of information with those who need it.\"

The dwarf looks at you with his small, sunken eyes, silently awaiting your response."

[bartender_default]="Durgin wipes down the counter with a worn rag before glancing your way.

\"Need a drink, supplies, or information?\"

The old dwarf rests his thick arms against the counter, waiting patiently."

[bartender_info_0]="Durgin scratches at his beard thoughtfully.
\"Most adventurers don't die in dungeons.
They die because they get careless.\""

[bartender_info_1]="\"If you're heading outside the city walls,
keep a few healing supplies on you.
You'll regret it the first time you don't.\""

[bartender_info_2]="The dwarf lets out a quiet grunt.
\"Monsters ain't always the worst thing you'll meet out there.
Remember that.\""

[bartender_info_3]="\"A good adventurer knows when to run.
The dead ones usually thought they were too strong for that.\""

[bartender_info_4]="Durgin taps the side of his mug.
\"People talk more after a few drinks.
You'd be surprised what information finds its way through this bar.\""

[bartender_info_5]="\"Dungeon layouts can shift sometimes.
Never trust your memory alone down there.\""

[bartender_info_6]="The bartender narrows his eyes slightly.
\"If a place suddenly goes quiet,
there's usually a reason for it.\""

[bartender_info_7]="\"Fresh adventurers spend all their coin on weapons.
Experienced ones spend it on staying alive.\""

[bartender_info_8]="Durgin chuckles to himself.
\"Every rank thinks they're tougher than the last one did.\""

[bartender_info_9]="\"You can learn a lot about a person
by how they treat the tavern staff.
Especially adventurers.\""

)

}

stored_chat_update