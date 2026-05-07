#!/usr/bin/env bash

stored_look_update() {

#-------------------------
#npc_look
#-------------------------
declare -gA npc_look=(

[clerk_default]="You study the clerk for a moment.

She moves with the kind of practiced efficiency that makes everyone else feel slow. 
Her Cornwall-blue dress is neat despite the endless stacks of parchment, ink, and half-finished forms surrounding her. 
Dark circles sit beneath sharp, focused eyes, the quiet mark of too many late nights and too few breaks.

She rarely looks up for long, her quill already moving before most people finish speaking. 
Even the loudest adventurers lower their voices near her desk.

Whatever keeps this guild standing… it’s probably passed through her hands first." 

)

#-------------------------
#object_look
#-------------------------
declare -gA object_look=(

[fandor_gh_door]="Your eyes drift to the heavy guild doors, thick oak bound with black iron and scarred by years of hard use.

They never seem to stay closed for long. Adventurers come through them covered in mud, blood, gold, or not at all.
A faded guild crest is carved into the center—worn smooth by countless hands pushing their way in...
and, for the lucky ones, back out." 

[fandor_gh_bar]="The guild bar is tucked into the western side of the hall. 
Where torchlight meets smoke and the smell of spilled ale never quite leaves the air.

Scarred mugs, loud laughter, and half-finished stories crowd every inch of it.
More rumors, contracts, and bad decisions have started here than anyone cares to admit."
)
}

stored_look_update