class_name ModifierHandler
extends Node

const MODIFIER = preload("res://scenes/modifier_handler/modifier.tscn")


func add_modifier_type(type: Modifier.ModifierType) -> void:
	if has_modifier(type):
		return # Already have one, don't add another.
	var new_modifier := MODIFIER.instantiate()
	new_modifier.type = type
	add_child(new_modifier)


func has_modifier(type: Modifier.ModifierType) -> bool:
	for modifier: Modifier in get_children():
		if modifier.type == type:
			return true
	return false


func get_modifier(type: Modifier.ModifierType) -> Modifier:
	# TODO If doesn't exist, create it
	for modifier: Modifier in get_children():
		if modifier.type == type:
			return modifier
	return null


func get_modified_value(base: int, type: Modifier.ModifierType) -> int:
	var modifier := get_modifier(type)
	
	if not modifier: # No such modifier found, no adjustment
		return base
	
	return modifier.get_modified_value(base)
