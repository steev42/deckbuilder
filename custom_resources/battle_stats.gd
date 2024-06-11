class_name BattleStats
extends Resource

var combatants : Array[EnemyStats] = []
var gold := 0

# Level and Pool should come from map node.
func get_battle_enemies(level: int, pool: BattlePool) -> Array[EnemyStats]:
	if not pool:
		return []
	var encounter_head = pool.get_random_creature_for_battle(level)
	gold += randi_range(encounter_head.min_gold, encounter_head.max_gold)
	pool.adjust_weights(encounter_head, Tweakables.repetitive_creature_multiplier)
	combatants.append(encounter_head.enemy_stats)
	var extra_creatures = encounter_head.fill_combat_encounter(level)
	for creature in extra_creatures:
		gold += randi_range(creature.min_gold, creature.max_gold)
		combatants.append(creature.enemy_stats)
	
	return combatants
