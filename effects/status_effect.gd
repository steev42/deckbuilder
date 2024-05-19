#meta-name: Effect 
#meta-description: Create an effect which can be applied to a target
class_name StatusEffect
extends Effect

var status : Status

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Combatant:
			target.status_handler.add_status(status)

