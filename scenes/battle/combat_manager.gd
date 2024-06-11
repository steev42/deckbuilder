class_name CombatManager
extends Node

enum Side {ALLY, PLAYER, ENEMY}

@onready var ally_handler: CombatantHandler = $AllyHandler
@onready var player_handler: CombatantHandler = $PlayerHandler
@onready var enemy_handler: CombatantHandler = $EnemyHandler

var active_handler = ally_handler

func _get_next_handler() -> CombatantHandler:
	if active_handler == ally_handler:
		return player_handler
	if active_handler == player_handler:
		return enemy_handler
	if active_handler == enemy_handler:
		return ally_handler
	return ally_handler


func _ready() -> void:
	var handlers = [ally_handler, player_handler, enemy_handler]

	for handler in handlers:
		#if not handler.setup_complete.is_connected(_on_setup_complete):
			#handler.setup_complete.connect(_on_setup_complete)
		if not handler.start_round_complete.is_connected(_on_start_round_complete):
			handler.start_round_complete.connect(_on_start_round_complete.bind(handler))
		if not handler.side_turn_complete.is_connected(_on_side_turn_complete):
			handler.side_turn_complete.connect(_on_side_turn_complete.bind(handler))
		if not handler.end_round_complete.is_connected(_on_end_round_complete):
			handler.end_round_complete.connect(_on_end_round_complete.bind(handler))


func _on_start_round_complete(handler: CombatantHandler) -> void:
	assert(active_handler==handler, "Ending start round of %s unexpectedly." % handler)
	active_handler = _get_next_handler()
	if active_handler == ally_handler:
		ally_handler.start_side_turn()
	else:
		active_handler.start_round()


func _on_end_round_complete(handler: CombatantHandler) -> void:
	assert(active_handler==handler, "Ending end round of %s unexpectedly." % handler)
	active_handler = _get_next_handler()
	if active_handler == ally_handler:
		ally_handler.start_round()
	else:
		active_handler.end_round()
	

func _on_side_turn_complete(handler: CombatantHandler) -> void:
	assert(active_handler==handler, "Ending turn of %s unexpectedly." % handler)
	active_handler = _get_next_handler()
	if active_handler == ally_handler:
		ally_handler.end_round()
	else:
		active_handler.start_side_turn()


func start_battle(players: Array[Stats], enemies: Array[Stats], allies: Array[Stats]) -> void:
	# Make sure our handlers are ready before we try to do stuff with them.
	if not is_node_ready():
		await ready
		
	# instead of just stepping through handlers list, do setup in this order
	# specifically: Player, Enemies, Allies.  It'll be somewhat rare
	# that allies start the battle in play, and we want to be sure player
	# and enemies get their own setup properly.
	
	# These methods should place creatures on the board, setup any card piles,
	# and TODO possibly arrange the UI to link to the player card piles.
	player_handler.setup_side(players, Combatant.TargetType.PLAYER)
	enemy_handler.setup_side(enemies, Combatant.TargetType.ENEMY)
	ally_handler.setup_side(allies, Combatant.TargetType.ALLY)
	
	# Now that everyone is setup, we can start the fight.  Allies go first!
	ally_handler.start_round()
	

func reset_battle() -> void:
	var handlers = [ally_handler, player_handler, enemy_handler]
	for handler: CombatantHandler in handlers:
		handler.reset_side()




