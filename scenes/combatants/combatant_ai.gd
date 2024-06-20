class_name Combatant_AI
extends Combatant

@onready var intent_ui: IntentUI = $IntentUI

var ai_action_picker: EnemyActionPicker # TODO Genericize this?
var current_action: EnemyAction : set = set_current_action

@export var ai: PackedScene

func _ready() -> void:
	Events.enemy_action_completed.connect(_on_action_completed)
	super._ready()

func check_for_death() -> void:
	if stats.health <= 0:
		queue_free()

func set_stats(value: Stats) -> void:
	if not value:
		return
	super.set_stats(value)
	# if our stats have changed, our intent may as well.
	if not stats.stats_changed.is_connected(update_action):
		stats.stats_changed.connect(update_action)

func prepare_for_turn() -> void:
	stats.regenerate_mana() # TODO probably in the stats, check for statuses
							# that effect turn-based mana
	stats.block = 0 # TODO check for statuses that affect block
	current_action = null
	update_action()
	do_turn()


func update_character() -> void:
	super.update_character()
	setup_ai()


func set_current_action(value: EnemyAction) -> void:
	current_action = value
	if current_action:
		intent_ui.update_intent(current_action.intent)


func setup_ai() -> void:
	if ai_action_picker:
		ai_action_picker.queue_free()
	
	if ai:
		var new_action_picker: EnemyActionPicker = ai.instantiate()
		add_child(new_action_picker)
		ai_action_picker = new_action_picker
		ai_action_picker.enemy = self
	else:
		print ("No AI found; enemy won't do anything!")


func update_action() -> void:
	print ("A")
	if not ai_action_picker:
		print ("B")
		return
	
	if not current_action:
		print ("C")
		current_action = ai_action_picker.get_action()
		return
	
	var new_conditional_action := ai_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		print ("D")
		current_action = new_conditional_action


func do_turn() -> void:
	do_action()

func do_action() -> void:
	if not current_action:
		return
	current_action.perform_action()

func _on_action_completed(enemy: Combatant) -> void:
	# If this isn't ourself, we don't care!
	if enemy != self:
		return
	
	# TODO If there is another action to do, do that (check mana, cards available, etc.)
	
	# Otherwise, do end of turn status effects
	status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)
