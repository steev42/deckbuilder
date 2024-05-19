class_name ExposedStatus
extends Status

const MODIFIER_NAME := "exposed"

var damage_multiplier := 0.5

func get_tooltip() -> String:
	return tooltip % {"multiplier": floori(damage_multiplier*100), "duration": current_value}


func initialize_status(target: Node) -> void:
	# Make sure target has a modifier handler
	assert(target.get("modifier_handler"), "No modifiers on %s" % target)
		
	# make sure you can add a damage taken modifier to it
	var dmg_taken_modifier : Modifier = target.modifier_handler.get_modifier(Modifier.ModifierType.DAMAGE_TAKEN)
	
	var exposed_modifier_value := dmg_taken_modifier.get_value(MODIFIER_NAME)
	
	# add the modifier value
	if not exposed_modifier_value:
		# It doesn't already exist, so create a new modifier
		exposed_modifier_value = ModifierValue.create_new_modifier(MODIFIER_NAME, ModifierValue.ValueType.PERCENTAGE_ADJUSTMENT)
		exposed_modifier_value.condition_value = damage_multiplier
		dmg_taken_modifier.add_value(exposed_modifier_value)
	
	# listen to events
	if not status_changed.is_connected(_on_status_changed):
		status_changed.connect(_on_status_changed.bind(dmg_taken_modifier))


func _on_status_changed(dmg_taken_modifier: Modifier) -> void:
	if current_value <= 0 and dmg_taken_modifier:
		dmg_taken_modifier.remove_value(MODIFIER_NAME)
