class_name CombatantHandler
extends Node

const COMBATANT = preload("res://scenes/combatants/combatant.tscn")
const COMBATANT_AI = preload("res://scenes/combatants/combatant_ai.tscn")

var acting_combatants: Array[Combatant]

#signal setup_complete(handler)
signal start_round_complete
signal side_turn_complete
signal end_round_complete

#var stats: Stats
var current_step : Callable

func _ready() -> void:
	# Listen for actions completed
	#combatant.battle_stage_ended.connect(_on_battle_stage_ended)
	# this only listens to those emitted from OUR combatant. 
	# think instead, there shouldn't be a specific combatant here
	# and we set that signal here?
	pass


func reset_side() -> void:
	for combatant: Combatant in get_children():
		combatant.queue_free()


func setup_side(side_stats: Array[Stats], target_type: Combatant.TargetType) -> void:
	# TODO Properly position enemies within the scene
	Tweakables.debug_print ("%s creatures found on side %s" % [len(side_stats),target_type], Tweakables.DEBUG_LEVELS.INFO)
	if len(side_stats) == 0:
		Tweakables.debug_print("No creatures found in %s" % Combatant.TargetType.keys()[target_type], Tweakables.DEBUG_LEVELS.WARN)
		return
	
	for creature in side_stats:
		if target_type == Combatant.TargetType.PLAYER:
			var creature_scene := COMBATANT.instantiate()
			#creature_scene.position
			# HACK Set target type BEFORE setting the stats
			# otherwise, it will be treated as an enemy and create a new
			# instance.
			creature_scene.target_type = target_type
			creature_scene.set_stats(creature)
			# HACK Hard coded position
			creature_scene.position = Vector2(120,240)
			add_child(creature_scene)
		else:
			var creature_scene := COMBATANT_AI.instantiate()
			if creature is EnemyStats:
				creature_scene.target_type = target_type
				creature_scene.set_stats(creature)
				# HACK Hard coded position
				creature_scene.position = Vector2(680,240)
				# CHECK Only add if we have the right stats?
				add_child(creature_scene)
	
	# for each child, listen to their signals as needed
	# initialize decks/discard/exhaust piles
	# etc.
	for child:Combatant in get_children():
		child.setup_for_battle()
		child.start_round_complete.connect(_on_combatant_start_round_complete.bind(child))
		child.turn_complete.connect(_on_combatant_turn_complete.bind(child))
		child.end_round_complete.connect(_on_combatant_end_round_complete.bind(child))
		child.combatant_died.connect(_on_combatant_died.bind(child))
		#child.status_handler.statuses_applied.connect(_on_statuses_applied.bind(child))
	
func _set_actors_for_phase() -> void:
	acting_combatants.clear()
	if get_child_count() == 0:
		return
	# Add all children to combatant array
	for child: Combatant in get_children():
		acting_combatants.append(child)
	

func start_round() -> void:
	# TODO This function can be made generic by passing in a callable!
	_set_actors_for_phase()
	current_step = _start_next_combatant_round
	current_step.call()


func _start_next_combatant_round() -> void:
	if acting_combatants.is_empty():
		start_round_complete.emit()
		return
	# Apply the start of round statuses.  This also will cause a signal when complete
	# that the child will react to.
	acting_combatants[0].status_handler.apply_statuses_by_type(Status.Type.START_OF_ROUND)


func _on_combatant_start_round_complete(c: Combatant) -> void:
	acting_combatants.erase(c)
	#_start_next_combatant_round()
	current_step.call()


func start_side_turn() -> void:
	if get_child_count() != 0:
		_set_actors_for_phase()
		current_step = _start_next_combatant_turn
		current_step.call()
		#_start_next_combatant_turn()


func _start_next_combatant_turn():
	if acting_combatants.is_empty():
		side_turn_complete.emit()
		return
	
	acting_combatants[0].status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)


func _on_combatant_turn_complete(c: Combatant) -> void:
	acting_combatants.erase(c)
	#_start_next_combatant_turn()
	current_step.call()


func end_round() -> void:
	if get_child_count() != 0:
		_set_actors_for_phase()
		current_step = _end_next_combatant_round
		current_step.call()
		#_end_next_combatant_round()


func _end_next_combatant_round() -> void:
	if acting_combatants.is_empty():
		end_round_complete.emit()
		return
	
	acting_combatants[0].status_handler.apply_statuses_by_type(Status.Type.END_OF_ROUND)


func _on_combatant_end_round_complete(c: Combatant) -> void:
	acting_combatants.erase(c)
	#_end_next_combatant_round()
	current_step.call()


func _on_combatant_died(c: Combatant) -> void:
	if acting_combatants.size() > 0:
		acting_combatants.erase(c)
		current_step.call()
		# TODO Do next step in side's turn?
	
