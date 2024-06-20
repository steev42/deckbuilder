class_name BattlePool
extends Resource

@export var pool : Array[BattleEntry] = []

#func get_battle_creatures(level: int) -> Array[Stats]:
	#var full_battle = Array[Stats]
	#var entry = get_random_creature_for_battle(level)
	#full_battle.append(entry.enemy_stats)
	#if entry:
		#var extras = entry.fill_combat_encounter(level)
		#for creature in extras:
			#full_battle.append(creature.enemy_stats)
	#return full_battle


func get_random_creature_for_battle(level: int) -> BattleEntry:
	var roll := randf_range(0.0, _get_total_weights_by_level(level))
	var accumulated_weight := 0.0
	for entry in _get_all_creatures_for_level(level):
		accumulated_weight += entry.adjusted_weight
		if roll <= accumulated_weight:
			return entry
	return null

func _get_total_weights_by_level(level: int) -> float:
	var sum_weight := 0.0
	for entry in _get_all_creatures_for_level(level):
		sum_weight += entry.adjusted_weight
	return sum_weight

func _get_all_creatures_for_level(level: int) -> Array[BattleEntry]:
	return pool.filter(
		func(creature: BattleEntry):
			return creature.min_level <= level and creature.max_level >= level
			)

func adjust_weights(entry: BattleEntry, weight: float) -> void:
	for pool_member in pool:
		if entry.id == pool_member.id:
			pool_member.adjusted_weight = clampf(pool_member.adjusted_weight * weight, 0.0, pool_member.default_weight)
		else:
			pool_member.adjusted_weight = clampf(pool_member.adjusted_weight + (pool_member.adjusted_weight * weight), 0.0, pool_member.default_weight)
