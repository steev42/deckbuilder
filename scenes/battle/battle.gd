extends Node2D

#@export var char_stats: Stats
@export var music : AudioStream
@export var battle_pool : BattlePool
@export var battle_level := 0

@onready var battle_ui: BattleUI = $BattleUI
#@onready var player_handler: PlayerHandler = $PlayerHandler
#@onready var player: Combatant_Player = $CombatantPlayer
#@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var combat_manager: CombatManager = $CombatManager
# TODO Should these go here, or should all related go through Combat Manager?
@onready var ally_handler: CombatantHandler = $CombatManager/AllyHandler
@onready var player_handler: CombatantHandler = $CombatManager/PlayerHandler
@onready var enemy_handler: CombatantHandler = $CombatManager/EnemyHandler

var battle_stats : BattleStats

func _ready() -> void:
	#normally, we would do this on a 'Run' level so we keep our health,
	#gold and deck between battles
	#var new_stats: Stats = char_stats.create_instance()
	#battle_ui.char_stats = new_stats
	#player.stats = new_stats  # THIS WILL BE REMOVED
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	#Events.enemy_turn_ended.connect(_on_enemy_turn_ended)

	#Events.player_turn_ended.connect(player_handler.end_turn)
	#Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)
	battle_stats = BattleStats.new()
	start_battle()


func start_battle() -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	#enemy_handler.reset_enemy_actions()
	#player_handler.start_battle(stats)
	#Now handled via signal : battle_ui.initialize_card_pile_ui()
	var enemies : Array[Stats] = battle_stats.get_battle_enemies(battle_level, battle_pool)
	combat_manager.start_battle([RunData.player_character_stats], enemies as Array[Stats], [])


#func _on_enemy_turn_ended() -> void:
	#player_handler.start_turn()
	#enemy_handler.reset_enemy_actions()


func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0:
		Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)


func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over", BattleOverPanel.Type.LOSE)

