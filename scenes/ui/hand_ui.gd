class_name HandUI
extends Control

@onready var hand: HBoxContainer = %Hand
@onready var card_ui = preload("res://scenes/cardui/card_ui.tscn")

var visually_discarding = false
#@export var char_stats: Stats : set = _set_char_stats

func _ready() -> void:
	for child in hand.get_children():
		child.queue_free()
	RunData.player_character_stats.hand.card_added.connect(add_card)
	RunData.player_character_stats.hand.card_removed.connect(discard_card)
	Events.player_discard_hand.connect(_on_player_discard_hand)
	Events.player_hand_discarded.connect(_on_player_hand_discarded)
	
#func _set_char_stats(value: Stats) -> void:
	#if not value:
		#Tweakables.debug_print("No value found", Tweakables.DEBUG_LEVELS.CRITICAL)
		#return
	#if not value.hand:
		#Tweakables.debug_print("No hand found", Tweakables.DEBUG_LEVELS.CRITICAL)
		#return
		
	#char_stats = value
	#char_stats.hand.card_pile_size_changed.connect(_on_hand_size_changed)
	
	
#func _on_hand_size_changed() -> void:
	#pass

func add_card(card: Card)->void:
	if card == null:
		Tweakables.debug_print("in hand_ui.add_card: null value", Tweakables.DEBUG_LEVELS.WARN)
		return
	
	var new_card_ui := card_ui.instantiate()
	hand.add_child(new_card_ui)
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.card = card
	new_card_ui.parent = hand
	new_card_ui.card_owner = RunData.player_character_stats


func discard_card(card: Card) -> void:
	# NOTE: Godot compares by reference.  So the card reference ID
	# should equal the card with the card UI.
	for child : CardUI in hand.get_children():
		if child.card == card:
			child.queue_free()

#func discard_card(card: CardUI) -> void:
	#print ("in handUI.discard_card")
	#print ("discard_card called; card = %s" % card.card_visuals.id)
	#card.queue_free()


func disable_hand() -> void:
	for card in get_children():
		card.disabled = true


# Put it back into our hand, and make sure it stays in the same location
# in the hand.
func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.disabled = true
	child.reparent(hand)
	var new_index := clampi (child.original_index, 0, get_child_count())
	move_child.call_deferred(child, new_index)
	child.set_deferred("disabled", false)


func _on_player_discard_hand() -> void:
	visually_discarding = true
	RunData.player_character_stats.hand.card_removed.disconnect(discard_card)
	var tween = create_tween()
	for card_ui: CardUI in hand.get_children():
		tween.tween_callback(card_ui.queue_free)
		tween.tween_interval(0.2) # TODO Magic Number
	visually_discarding = false


func _on_player_hand_discarded() -> void:
	while visually_discarding:
		pass
	RunData.player_character_stats.hand.card_removed.connect(discard_card)
