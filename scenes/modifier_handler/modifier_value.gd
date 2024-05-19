class_name ModifierValue
extends Node

#TODO Damage Types?  Are these considered modifiers in the same way?

enum ValueType { # The following are listed in the order they should be interpreted
	FLAT_ADJUSTMENT,
	PERCENTAGE_ADJUSTMENT,
	MINIMUM_VALUE,
	MAXIMUM_VALUE,
	CONDITIONAL_MINIMUM, # Conditions should be based *entirely* on the current value.
	CONDITIONAL_MAXIMUM,
	OVERRIDE,
	CONDITIONAL_OVERRIDE
}

enum ConditionalType {
	UNCONDITIONAL,
	LESS_THAN,
	GREATER_THAN,
	EQUAL
}

@export var type: ValueType
# The original version had two values; I don't see the need for that. It just
# makes all accessors need to check type before getting the value. Instead, 
# if value needs to be an int, the end value will know that and can floor 
# appropriately.
@export var value: float
@export var source: String
@export var condition: ConditionalType = ConditionalType.UNCONDITIONAL
@export var condition_value: int


func apply_modifier(check_val : int) -> bool:
	match condition:
		ConditionalType.UNCONDITIONAL:
			return true
		ConditionalType.LESS_THAN:
			if check_val < condition_value:
				return  true
		ConditionalType.GREATER_THAN:
			if check_val > condition_value:
				return true
		ConditionalType.EQUAL:
			if check_val == condition_value:
				return true	
	return false


static func create_new_modifier(modifier_source: String, what_type: ValueType) -> ModifierValue:
	var new_modifier := new()
	new_modifier.source = modifier_source
	new_modifier.type = what_type
	
	return new_modifier

func _to_string() -> String:
	var result = ("ModifierValue: type=%, value=%, source=%" % [type, value, source])
	return result
