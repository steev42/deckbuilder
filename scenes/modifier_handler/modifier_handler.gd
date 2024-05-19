class_name ModifierHandler
extends Node

const MODIFIER = preload("res://scenes/modifier_handler/modifier.tscn")


func has_modifier(type: Modifier.ModifierType) -> bool:
	for modifier: Modifier in get_children():
		if modifier.type == type:
			return true
	return false


func get_modifier(type: Modifier.ModifierType) -> Modifier:
	for modifier: Modifier in get_children():
		if modifier.type == type:
			return modifier
	# If we get to this point, one doesn't exist, so create one.
	var new_modifier := MODIFIER.instantiate()
	new_modifier.type = type
	add_child(new_modifier)
	# I'd love to name the node created here, but in the end, I don't think it 
	# matters, and it doesn't appear that Godot has the ability to name a node
	# during runtime.
	return new_modifier


func get_modified_value(base: int, type: Modifier.ModifierType) -> int:
	var modifier := get_modifier(type)
	print ("In get_modified_value")
	if not modifier: # No such modifier found, no adjustment
		return base
	print ("Modifier found, getting value")
	return modifier.get_modified_value(base)
