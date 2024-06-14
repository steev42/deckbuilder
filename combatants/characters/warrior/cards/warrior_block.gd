extends Card

func apply_effects(targets: Array[Node]) -> void:
	Tweakables.debug_print("Block was played; targeting %s" % len(targets), Tweakables.DEBUG_LEVELS.DEBUG)
	var block_effect := BlockEffect.new()
	block_effect.amount = 5
	block_effect.sound = sound
	block_effect.execute(targets)
