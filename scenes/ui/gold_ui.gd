class_name GoldUI
extends HBoxContainer

#@export var run_stats: RunStats : set = set_run_stats

@onready var label: Label = $Label

func _ready() -> void:
	label.text = "0"
	if not Events.run_stats_created.is_connected(_on_run_stats_created):
		Events.run_stats_created.connect(_on_run_stats_created)

func _on_run_stats_created() -> void:
	if not RunData.run_stats.gold_changed.is_connected(_update_gold):
		RunData.run_stats.gold_changed.connect(_update_gold)
		_update_gold()

#func set_run_stats(new_value: RunStats) -> void:
	#run_stats = new_value
	#
	#if not run_stats.gold_changed.is_connected(_update_gold):
		#run_stats.gold_changed.connect(_update_gold)
		#_update_gold()


func _update_gold() -> void:
	label.text = str(RunData.run_stats.gold)
