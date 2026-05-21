#!/usr/bin/env bash

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

Registration, collection, or just here to bother me?
"

[clerk_collection]="I only deal with registered adventurers."

[clerk_class]="She drags a quill across the page without looking up. 
\"Alright… you wrote down ${name}. That’s something.\"

A pause. She squints at the parchment like it personally offended her.

\"Now I need a class. Try to pick one without wasting both of our time.\"
She finally glances up at you—tired, unimpressed.

\"Go on. What are you?\"


${BOLD}W)arrior${RESET} — Front line. Steel, muscle, and bad decisions. 
You’ll hit harder the more experienced you get.

${BOLD}C)leric${RESET} — Keep people alive. Or try to. 
More durable than you look, if you stick with it.

${BOLD}M)age${RESET} — Books, spells, and things catching fire. 
Your mana pool will grow fast.

${BOLD}P)aladin${RESET} — Bit of everything. Discipline, control… 
and a tendency to think you’re right.


She taps the page impatiently. \"Well?\"

"
[clerk_race]="She flips to the next page with a sharp flick of her wrist.
\"Race. Try not to make this one complicated.\"
Her eyes scan you quickly, like she’s already made up her mind 
and just needs it confirmed.

${DIM}Race won't have any effect on gameplay 
but could lead to some different social interactions.${RESET}


${BOLD}H)uman${RESET} — \"Reliable. Adaptable. Everywhere. 
You’ll fit in just fine.\"

${BOLD}E)lf${RESET} — \"Graceful, long-lived… and usually aware of it. 
Try not to look down on everyone.\"

${BOLD}D)warf${RESET} — \"Stubborn, tough, and loud about both. 
At least you’ll survive.\"

${BOLD}O)rc${RESET} — \"Strong. Direct. People will assume things. 
They’re not always wrong.\"

${BOLD}Hf)Halfling${RESET} — \"Small, quiet, and underestimated. 
Probably the smartest way to stay alive, honestly.\"


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

)

}

stored_chat_update