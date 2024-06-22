class_name HandUI
extends Control

@onready var hand: HBoxContainer = %Hand
@onready var card_ui = preload("res://scenes/cardui/card_ui.tscn")

var visually_discarding = false
#@export var char_stats: Stats : set = _set_char_stats

func _ready() -> void:
	for child in hand.get_children():
		print ("calling queue_free to remove placeholders/old cards")
		child.queue_free()
	RunData.player_character_stats.hand.card_added.connect(add_card)
	RunData.player_character_stats.hand.card_removed.connect(discard_card)
	Events.player_discard_hand.connect(_on_player_discard_hand)
	Events.player_hand_discarded.connect(_on_player_hand_discarded)
	
func add_card(card: Card)->void:
	if card == null:
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
	print ("getting rid of card visual: Card=%s (%s)" % [card, card.id])
	print ("Before removal; showing %s cards" % hand.get_child_count())
	for child : CardUI in hand.get_children():
		if child.card == card:
			print ("Calling queue_free to remove disarded card; id=%s" % child.card)
			child.queue_free()
		else:
			print ("Look at %s (%s); not discarding." % [child.card, child.card.id])
	print ("After removal; showing %s cards" % hand.get_child_count())
	

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
	print ("disconnecting card_removed")
	RunData.player_character_stats.hand.card_removed.disconnect(discard_card)
	var tween = create_tween()
	for discard_card_ui: CardUI in hand.get_children():
		print ("Tween->calling queue_free because hand discarded")
		tween.tween_callback(discard_card_ui.queue_free)
		tween.tween_interval(0.2) # TODO Magic Number
	tween.finished.connect(func(): visually_discarding = false)


func _on_player_hand_discarded() -> void:
	while visually_discarding:
		pass
	if not RunData.player_character_stats.hand.card_removed.is_connected(discard_card):
		print ("reconnected")
		RunData.player_character_stats.hand.card_removed.connect(discard_card)
	else:
		print ("reconnection failed because already connected?")
