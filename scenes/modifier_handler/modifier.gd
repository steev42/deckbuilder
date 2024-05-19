class_name Modifier
extends Node

enum ModifierType{
	NO_MODIFIER = -1,
	DAMAGE_DEALT,
	DAMAGE_TAKEN,
	CARD_COST,
	SHOP_COST,
	CARDS_DRAWN,
	CARDS_RETAINED,
	CAMPFIRE_ACTIONS,
	BLOCK_GAINED,
}

@export var type: ModifierType


func get_value(source: String) -> ModifierValue:
	for value: ModifierValue in get_children():
		if value.source == source:
			return value
	return null


func add_value(value: ModifierValue) -> void:
	var modifier_value := get_value(value.source)
	if not modifier_value:
		add_child(value)
	else:
		modifier_value.value = value.value


func remove_value(source: String) -> void:
	for value: ModifierValue in get_children():
		if value.source == source:
			value.queue_free()


func clear_values() -> void:
	for value: ModifierValue in get_children():
		value.queue_free()


func get_modified_value(base: int) -> int:
	print ("In modifier.get_modified_value")
	var flat_adjustment: int = base
	var percent_adjustment: float = 1.0
	var min_value: int = floori(-INF)
	var max_value: int = floori(INF)
	var has_override : bool = false
	var has_conditional: bool = false
	var override: int = 0
	var has_cond_override = false
	var cond_override = 0
	
	print (get_children())
	
	for value: ModifierValue in get_children():
		print (value)
		match value.type:
			ModifierValue.ValueType.FLAT_ADJUSTMENT:
				flat_adjustment += floori(value.value)
				print ("New flat adjustment: %s " % flat_adjustment)
			ModifierValue.ValueType.PERCENTAGE_ADJUSTMENT:
				percent_adjustment += value.value # Multiply, not add?
				print ("New percentage adjustment: %s" % percent_adjustment)
			ModifierValue.ValueType.MINIMUM_VALUE:
				min_value = floori(max(min_value, value.value))
			ModifierValue.ValueType.MAXIMUM_VALUE:
				max_value = floori(min(max_value, value.value))
			ModifierValue.ValueType.OVERRIDE:
				override = floori(value.value)  # What do we do with multiple override values?
				has_override = true
			ModifierValue.ValueType.CONDITIONAL_MINIMUM, ModifierValue.ValueType.CONDITIONAL_MAXIMUM, ModifierValue.ValueType.CONDITIONAL_OVERRIDE:
				has_conditional = true
			_:
				continue
	print ("Got through all modifier values...")
	return floori(flat_adjustment * percent_adjustment)
	
	var adjusted_value =  floori(min(max((flat_adjustment * percent_adjustment), min_value), max_value))
	
	if has_override and not has_conditional:
		return floori(override)
	
	# Can we do things like Boot, where if X is < Y, it becomes Y?  Or if X < Y, it becomes 1?
	if has_conditional:
		min_value = floori(-INF)
		max_value = floori(INF)

		
		for value: ModifierValue in get_children():
			match value.type:
				ModifierValue.ValueType.CONDITIONAL_MINIMUM:
					if value.apply_modifier(adjusted_value):
						min_value = max(min_value, value.value)
				ModifierValue.ValueType.CONDITIONAL_MAXIMUM:
					if value.apply_modifier(adjusted_value):
						max_value = min(max_value, value.value)
				ModifierValue.ValueType.CONDITIONAL_OVERRIDE:
					if value.apply_modifier(adjusted_value):
						cond_override = value.value
						has_cond_override = true
				_:
					continue
	
	if has_override and not has_cond_override:
		return floori(override)
	
	if has_cond_override:
		return floori(cond_override)
	
	return min(max(adjusted_value, min_value), max_value)
