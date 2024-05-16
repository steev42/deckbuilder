# Clone the Spire

This project started life as a youtube tutorial to learn Godot as a Slay the Spire clone.
(see https://www.youtube.com/watch?v=ulgh_neTJG8&list=PL6SABXRSlpH8CD71L7zye311cp9R4JazJ)

Since then, it has evolved somewhat, as I try to branch out on my own. There 
are still lots of Slay the Spire influences, but I hope over time to make it more 
of its own thing.

## Plans

The idea here is to make some updates to the formula.  Probably nothing exceptional
but at least switch things up slightly.

### The Map

My plan for the map is to make it free-movement along paths; you can retreat if 
you want.  This obviously means two things -- A) nodes you have already passed
through should probably reset after a while and B) if you stick with STS style
game play, eventually you can outpace the things you are fighting just by 
sticking in the lower-strength areas until you have what you need.  To counter 
that, the idea is this.  The villain starts out in one location.  They exert
influence on nearby nodes for every day that passes.  When a hero moves along a 
path to a new node, X days pass, maybe depending on the length of the node? 
When the nodes next to a villain gain Y influence from the villain, they switch
to evil nodes; shops would get more expensive, enemies more difficult, healing
less effective. Those nodes would then start influencing their neighboring nodes.
Perhaps there could even be evil 'levels' that slowly spread out from the starting
node. If the player's starting node (city) is overrun and turns evil, they lose.
This gives them the impetus to not wait too long to take on the villain of the 
act.

### Origin

I don't have anything firm here, but I'd like each run to select two things,
an origin and a class.  The origin would be like a D&D Race/Species.  I have names
in mind, but not a real idea of how I want the effect to be.  Possible ideas
include additional cards (2-5) in your starting deck, starting 'relics', or 
just base passive abilities that aren't tied to a relic (is that necessary?)

* Stormforged
* Mountainborn
* Leafblown

### Classes

Like Slay the Spire, the idea is to have classes.  In the youtube project, three
classes were created as an example, though only the Warrior class had any cards,
the other two just being clones so there was the possiblity of selecting others.
I actually came up with some ideas as to how I would like these classes to function,
but as of 15 May 2024, they haven't had any work done towards that end yet.

#### Warrior

The warrior should excel at physical damage to single targets. Dealing damage to
multiple targets at the same time should be possible, but be much weaker. The 
warrior should also find it easy to gain block against physical damage, but be 
hard-pressed to ignore any elemental damage. The card draw and mana gain mechanisms
should be the simplest to understand, refreshing both completely every turn. 
Perhaps there can be some sort of rage mechanic?

#### Wizard

This should be the elemental specialist.  My idea here is that the wizard is very
much a class that tries to survive until he can deal a high-mana attack. To that 
end, he gains limited mana every turn, but it doesn't reset either.  Similarly,
cards don't draw easily for the wizard -- cards should stay in hand until they 
are used, at which point they are automatically replaced. Most cards should do
generic 'elemental' damage, but the wizard should *always* have a card available
that will allow him to focus in a specific element if needed. Most damaging cards
should be high mana/high damage (i.e. 8 Mana, 40 elemental damage).

#### Assassin

The assassin should be about avoiding notice until the time is right to strike.
Defensive cards, instead of being block, should instead give a chance to avoid 
damage altogether; but if he is hit he will take full damage.  Damaging cards
should have an automatic increase to damage based on how many turns have passed 
since damage was dealt by the assassin (turns spent observing).  There should
be the ability to do minimal effects that do not ruin this bonus -- cards that
provide an 'exposed' that doesn't decrease until an attack is made, for instance.

#### Summoner

Not currently even selectable, this was another idea I had for a class.  This 
would be all about calling minions to do your bidding, filling up the heroes side
of the board.  These miniosn would all have their own mini-decks, and would 
choose their own actions each turn, acting after the hero but before the monsters.
Summoned creatures should be able to be dismissed; probably by creating temporary
cards that are free and stay in your hand.  There should be a penalty for summoning
a creature -- mana or card draw?  Maybe different per creature?
