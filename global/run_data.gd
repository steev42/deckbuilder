extends Node

const WARRIOR = preload("res://combatants/characters/warrior/warrior.tres")

# TODO Currently defaulting to warrior; is this right?
var player_character_stats: Stats = WARRIOR.create_instance() : set = _set_run_player_character

var run_stats : RunStats : set = _set_run_stats

func _set_run_stats(value) -> void:
	run_stats = value
	Events.run_stats_created.emit()

func _set_run_player_character(value) -> void:
	player_character_stats = value
	Events.run_character_created.emit()

# TODO Probably add MAP, ACT?  List of seen relics if we want to limit to once
# each?  
