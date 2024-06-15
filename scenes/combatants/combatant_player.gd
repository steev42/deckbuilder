class_name Combatant_Player
extends Combatant

func _ready() -> void:
	target_type = TargetType.PLAYER
	#Events.player_turn_ended.connect(_on_player_turn_end)


func _on_player_turn_end() -> void:
	turn_complete.emit()


func check_for_death() -> void:
	if stats.health <= 0:
		Events.player_died.emit()
		queue_free()
		
