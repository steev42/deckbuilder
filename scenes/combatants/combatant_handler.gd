class_name CombatantHandler
extends Node

@export var combatant: Combatant

var stats: Stats

func _ready() -> void:
	# Listen for actions completed
	pass


func start_battle(_stats: Stats) -> void:
	stats = _stats
	# Set up draw, discard, exhaust piles
	# Shuffle draw pile
	# Right now, enemies don't have decks, but they should
	# Setup statuses_applied listener
	pass


func start_round() -> void:
	# draw everyone's cards, setup ally/enemy intents
	pass


func start_side_turn() -> void:
	# Do anything that needs to be done before the side (player, ally, enemy)
	# starts their turn.  Do before turn statuses go here for before each
	# individual combatant?
	pass


func start_combatant_turn() -> void:
	# Do anything that needs to be done before the combatant begins their turn
	# Reset block, update mana, apply statuses.
	pass


func end_combatant_turn() -> void:
	pass


func end_side_turn() -> void:
	pass


func end_battle() -> void:
	pass
	

func draw_card() -> void:
	pass


func draw_cards(amount: int) -> void:
	pass


func discard_cards() -> void:
	pass


func _on_card_played(card: Card) -> void:
	pass


func _on_statuses_applied(type: Status.Type) -> void:
	pass
