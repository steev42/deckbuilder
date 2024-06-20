class_name BattleUI
extends CanvasLayer

#@export var char_stats: Stats : set = _set_char_stats

@onready var hand_ui: HandUI = $HandUI
@onready var mana_ui: ManaUI = $ManaUI as ManaUI
@onready var end_turn_button: Button = %EndTurnButton
@onready var draw_pile_button: CardPileOpener = %DrawPileButton
@onready var discard_pile_button: CardPileOpener = %DiscardPileButton
@onready var draw_pile_view: CardPileView = %DrawPileView
@onready var discard_pile_view: CardPileView = %DiscardPileView


func _ready() -> void:
	Events.player_battle_setup_complete.connect(_on_player_battle_setup_complete)
	Events.player_turn_started.connect(_on_player_turn_started)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	draw_pile_button.pressed.connect(draw_pile_view.show_current_view.bind("Draw Pile", true))
	discard_pile_button.pressed.connect(discard_pile_view.show_current_view.bind("Discard Pile"))
	

func _on_player_battle_setup_complete() -> void:
	initialize_card_pile_ui()
	

func initialize_card_pile_ui() -> void:
	draw_pile_button.card_pile = RunData.player_character_stats.draw_pile
	draw_pile_view.card_pile = RunData.player_character_stats.draw_pile
	discard_pile_button.card_pile = RunData.player_character_stats.discard
	discard_pile_view.card_pile = RunData.player_character_stats.discard


#func _set_char_stats(value : Stats) -> void:
	#char_stats = value
	#mana_ui.char_stats = char_stats
	#hand_ui.char_stats = char_stats


func _on_player_hand_drawn() -> void:
	end_turn_button.disabled = false


func _on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	Events.player_turn_ended.emit()
	
func _on_player_turn_started() -> void:
	end_turn_button.disabled = false
