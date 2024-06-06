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
	stats.draw_pile = stats.deck.duplicate()
	
	# Let's make sure that there is now a draw pile before we do other things.
	# Since when we first test this, we're still using action pickers for AI
	# creatures instead of decks.
	if len(stats.draw_pile.cards) > 0:
		stats.draw_pile.shuffle()
		stats.discard = CardPile.new()
		# TODO Hand initialization?
		# Right now, Hand is an HBoxContainer and each card is unique within it
		# That doesn't really work for non-player actors.  So we will need some
		# way to remember/determine which cards creatures are drawing that doesn't
		# rely on the Hand UI scene.

func start_round() -> void:
	# The following method is called by the handler to actually start the
	# combatant's round.
	#status_handler.apply_statuses_by_type(Status.Type.START_OF_ROUND)
	
	stats.regenerate_mana() # TODO probably in the stats, check for statuses
							# that effect turn-based mana
	stats.block = 0 # TODO check for statuses that affect block
	
	#TODO  Draw cards!
	
	start_round_complete.emit()

func end_round() -> void:
	# discard cards
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
	print ("In take_damage function")
	var modified_damage := modifier_handler.get_modified_value(amount, Modifier.ModifierType.DAMAGE_TAKEN)
	print ("dealing damage: {amount} is modified into {modded}" % {"amount":amount, "modded" : modified_damage})
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
