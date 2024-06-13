class_name HandUI
extends Control

@onready var hand: HBoxContainer = %Hand
@onready var card_ui = preload("res://scenes/cardui/card_ui.tscn")

@export var char_stats: Stats : set = _set_char_stats

func _ready() -> void:
	for child in hand.get_children():
		child.queue_free()

func _set_char_stats(value: Stats) -> void:
	if not value:
		Tweakables.debug_print("No value found", Tweakables.DEBUG_LEVELS.CRITICAL)
		return
	if not value.hand:
		Tweakables.debug_print("No hand found", Tweakables.DEBUG_LEVELS.CRITICAL)
		return
		
	char_stats = value
	#char_stats.hand.card_pile_size_changed.connect(_on_hand_size_changed)
	char_stats.hand.card_added.connect(add_card)
	
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
	new_card_ui.char_stats = char_stats


func discard_card(card: CardUI) -> void:
	card.queue_free()


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
