extends Card

const EXPOSED = preload("res://statuses/exposed.tres")
@export var optional_sound: AudioStream

func apply_effects(targets: Array[Node]) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount=10
	damage_effect.sound=sound
	damage_effect.execute(targets)
	
	var status_effect := StatusEffect.new()
	var exposed_effect = EXPOSED.duplicate()
	exposed_effect.current_value = 2
	status_effect.status = exposed_effect
	status_effect.execute(targets)


