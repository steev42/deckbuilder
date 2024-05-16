class_name EnemyActionPicker
extends Node

@export var enemy: Combatant: set = _set_enemy
@export var target: Combatant: set = _set_target

@onready var total_weight := 0.0

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	setup_chances()
	
func get_action() -> EnemyAction:
	var action := get_first_conditional_action()
	if action:
		return action
	
	return get_chance_based_action()
	

func get_first_conditional_action() -> EnemyAction:
	var action: EnemyAction
	
	for child in get_children():
		action = child as EnemyAction
		if not action or action.type != EnemyAction.Type.CONDITIONAL:
			continue
		
		if action.is_performable():
			return action
	return null

func get_chance_based_action() -> EnemyAction:
	var action: EnemyAction
	var roll := randf_range(0.0, total_weight)
	for child in get_children():
		action = child as EnemyAction
		if not action or action.type != action.Type.CHANCE_BASED:
			continue
		
		if action.accumulated_weight > roll:
			return action
	
	return null # Should probably throw an exception?
	
func setup_chances() -> void:
	for action: EnemyAction in get_children():
		if not action or action.type != action.Type.CHANCE_BASED:
			continue
		total_weight += action.chance_weight
		action.accumulated_weight = total_weight
		
func _set_enemy(value: Combatant) -> void:
	enemy = value
	for action in get_children():
		action.enemy = enemy

func _set_target(value: Combatant) -> void:
	target = value
	for action in get_children():
		action.target = target
