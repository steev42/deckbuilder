extends Node

enum DEBUG_LEVELS {OFF, INFO, DEBUG, WARN, CRITICAL, ALL}

# Debug settings
var debug_level : DEBUG_LEVELS = DEBUG_LEVELS.DEBUG
func debug_print(message: String, level: DEBUG_LEVELS) -> void:
	if debug_level == DEBUG_LEVELS.OFF:
		return
	if level >= debug_level:
		print ("[%s] %s" % [DEBUG_LEVELS.keys()[level], message])

# Gameplay settings (shouldn't affect difficulty)
var repetitive_creature_multiplier := 0.2

# Difficulty settings
var additional_hand_draw_player := 0
var additional_mana_per_turn_player := 0
var increased_maximum_mana_player := 0.0
var increased_maximum_life_player := 0.0

var additional_hand_draw_enemy := 0
var additional_mana_per_turn_enemy := 0
var increased_maximum_mana_enemy := 0.0
var increased_maximum_life_enemy := 0.0


