class_name BattleEntry
extends Resource

# This class is the base class used to determine the creatures that will
# be in a single map node.  Additional creatures will be added based entirely
# upon the first creature chosen for the combat.

@export var id : String
@export var min_gold := 0
@export var max_gold := 100
@export var default_weight := 1.0
var adjusted_weight = default_weight
@export var enemy_stats : EnemyStats
# TODO DO monsters adjust with level? Is this where we want to have that data if so?
@export var min_level := 0
@export var max_level := 20

# By default, no additional creatures
@export var additional_creature_weights := [1.0, 0.0, 0.0, 0.0, 0.0]

@export var additional_creature_pool : BattlePool

func fill_combat_encounter(level: int) -> Array[BattleEntry]:
	var extra_creatures = []
	for i in _get_number_of_additional_creatures():
		extra_creatures.append(additional_creature_pool.get_random_creature_for_battle(level))
		# NOTE This pull from the pool does *NOT* adjust weights; all creatures should use their
		# default weighting at all times. Multiple of the same creature can and should appear in
		# a single combat.
	return extra_creatures
	
func _get_number_of_additional_creatures() -> int:
	var accumulated_weight = 0.0
	for i in len(additional_creature_weights):
		accumulated_weight += additional_creature_weights[i]
	var roll := randf_range(0.0, accumulated_weight)
	accumulated_weight = 0.0
	for i in len(additional_creature_weights):
		accumulated_weight += additional_creature_weights[i]
		if accumulated_weight <= roll:
			return i
	return 0
