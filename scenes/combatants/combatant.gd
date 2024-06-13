class_name Combatant
extends Area2D

enum TargetType {PLAYER, ENEMY, ALLY}
const WHITE_SPRITE_MATERIAL := preload("res://art/white_shader_material.tres")

@onready var image: Sprite2D = %Image
@onready var pointer: Sprite2D = %Pointer
@onready var stats_ui: StatsUI = $StatsUI
@onready var status_handler: StatusHandler = $StatusHandler
@onready var modifier_handler: ModifierHandler = $ModifierHandler

signal start_round_complete
signal turn_complete
signal end_round_complete

signal combatant_died

@export var target_type : TargetType = TargetType.ENEMY

@export var stats: Stats : set = set_stats


func _ready() -> void:
	status_handler.status_owner = self
	status_handler.statuses_applied.connect(_on_statuses_applied)


func set_stats(value:Stats) -> void:
	if not value:
		return
	if not is_node_ready:
		await ready
	# If AI, need to create new instance. If player, instance created in
	# run script (eventually--currently battle).
	if target_type == TargetType.PLAYER:
		stats = value
	else:
		stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
	if not stats.death_check_required.is_connected(check_for_death):
		stats.death_check_required.connect(check_for_death)
	
	update_character()
	

func setup_for_battle() -> void:
	# TODO For Allies & Enemies, make sure starting deck is properly
	# configured.
	Tweakables.debug_print ("Setting up for battle - %s" % stats.character_name, Tweakables.DEBUG_LEVELS.INFO)
	Tweakables.debug_print ("Taking a look at the deck; %s cards found." % stats.deck.size(), Tweakables.DEBUG_LEVELS.INFO)
	stats.draw_pile = stats.deck.duplicate()
	Tweakables.debug_print ("Draw pile created; %s cards found." % stats.draw_pile.size(), Tweakables.DEBUG_LEVELS.INFO)
	# Let's make sure that there is now a draw pile before we do other things.
	# Since when we first test this, we're still using action pickers for AI
	# creatures instead of decks.
	if stats.draw_pile.size() > 0:
		stats.draw_pile.shuffle()
		
		if stats.discard == null:
			stats.discard = CardPile.new()
		else:
			stats.discard.clear()
			
		if stats.hand == null:
			stats.hand = CardPile.new()
		else:
			stats.hand.clear()
	if target_type == TargetType.PLAYER:
		Events.player_battle_setup_complete.emit()

func draw_cards(amount: int) -> void:
	Tweakables.debug_print("Drawing %s cards" % amount, Tweakables.DEBUG_LEVELS.INFO)
	var tween := create_tween()
	for i in range (amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(0.2) # TODO Make this a constant
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit())

func draw_card() -> void:
	reshuffle_deck_from_discard()
	stats.hand.add_card(stats.draw_pile.draw_card())

func reshuffle_deck_from_discard() -> void:
	if not stats.draw_pile.empty():
		return
	while not stats.discard.empty():
		stats.draw_pile.add_card(stats.discard.draw_card())
	stats.draw_pile.shuffle()

func start_round() -> void:
	# The following method is called by the handler to actually start the
	# combatant's round.
	#status_handler.apply_statuses_by_type(Status.Type.START_OF_ROUND)	
	stats.regenerate_mana() # TODO probably in the stats, check for statuses
							# that effect turn-based mana
	stats.block = 0 # TODO check for statuses that affect block
	#HACK Draw Cards
	if target_type == TargetType.PLAYER:
		draw_cards(stats.cards_per_turn)
		
	start_round_complete.emit()

func end_round() -> void:
	# TODO discard cards
	end_round_complete.emit()


func update_stats() -> void:
	stats_ui.update_stats(stats)


func update_character() -> void:
	if not stats is Stats:
		return
	if not is_inside_tree():
		await ready
	
	image.texture = stats.portrait
	update_stats()


func take_damage(amount:int) -> void:
	# TODO I don't like that taking the damage and showing the feedback are
	# 	in the same function. Can we do something about that?
	if stats.health <= 0:
		return
	Tweakables.debug_print ("In take_damage function", Tweakables.DEBUG_LEVELS.INFO)
	var modified_damage := modifier_handler.get_modified_value(amount, Modifier.ModifierType.DAMAGE_TAKEN)
	Tweakables.debug_print ("dealing damage: {amount} is modified into {modded}" % {"amount":amount, "modded" : modified_damage}, Tweakables.DEBUG_LEVELS.INFO)
	# Turn white and shake the sprite a little, then reset.
	image.material = WHITE_SPRITE_MATERIAL
	var tween := create_tween()
	# shake the sprite
	tween.tween_callback(Shaker.shake.bind(self, 15, 0.15))
	# actually deal the damage
	tween.tween_callback(stats.take_damage.bind(modified_damage))
	tween.tween_interval(0.17)
	
	tween.finished.connect(func():
		image.material = null
		
		if stats.health <= 0:
			combatant_died.emit()
			queue_free() # TODO Should this be here?
		)


# Placeholder function in case I want to do something like this later.
func heal(_amount:int) -> void:
	pass

func do_turn()-> void:
	# Do nothing here.  In the extending classes, this can be overwritten to
	# actually do something.  But it's being called from the base class, so
	# needs to have a placeholder function here.
	pass

func check_for_death() -> void:
	pass

func _on_statuses_applied(type: Status.Type) -> void:
	match type:
		Status.Type.START_OF_ROUND:
			start_round()
		Status.Type.START_OF_TURN:
			do_turn()
		Status.Type.END_OF_TURN:
			turn_complete.emit()
			# This allows the next actor to start moving, but it is done
			# in the handler and/or the manager.
		Status.Type.END_OF_ROUND:
			end_round()

# TODO On the following two functions, they will *always* show the pointer. 
# Should try to set something up that the pointer is only visible if the 
# entered character is a valid target for the card. 
# In the youtube tutorial, players didn't have a pointer, and allies didn't
# exist, so this wasn't an issue. If the card needed a target, all combatants
# with pointers were enemies, so you would always show the target.
# Area2D in these functions is the CardUI's DropPointDetector.
func _on_area_entered(_area: Area2D) -> void:
	pointer.show()


func _on_area_exited(_area: Area2D) -> void:
	pointer.hide()
