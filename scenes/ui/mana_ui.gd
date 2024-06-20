class_name ManaUI
extends Panel

# CHECK We're currently forcing this to show PLAYER mana data.
# Do we need to make this more generic for other creatures?

#@export var char_stats: Stats: set = _set_char_stats

@onready var mana_label: Label = $ManaLabel

func _ready() -> void:
	if not RunData.player_character_stats.stats_changed.is_connected(_on_stats_changed):
		RunData.player_character_stats.stats_changed.connect(_on_stats_changed)

# never called!
#func _set_char_stats(value: Stats) -> void:
	##char_stats = value
	#
	#if not is_node_ready():
		#await ready
	#
	#_on_stats_changed()

func _on_stats_changed() -> void:
	mana_label.text = "%s/%s" % [RunData.player_character_stats.mana, RunData.player_character_stats.max_mana]
