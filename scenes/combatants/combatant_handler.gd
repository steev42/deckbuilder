class_name CombatantHandler
extends Node

var acting_combatants: Array[Combatant]

#signal setup_complete(handler)
signal start_round_complete
signal side_turn_complete
signal end_round_complete

var stats: Stats
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


func setup_side() -> void:
	# TODO Initialize all children, set their stats
	# ^^ That's going to be the hard part here, I think.
	
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
	if get_child_count() != 0:
		_set_actors_for_phase()
		current_step = _start_next_combatant_round
		current_step.call()
		#_start_next_combatant_round()


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
	
