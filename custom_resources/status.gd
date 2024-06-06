class_name Status
extends Resource

signal status_applied(status: Status)
signal status_changed

enum Type {START_OF_ROUND, START_OF_TURN, END_OF_TURN, END_OF_ROUND, EVENT_BASED}
# Event based for things like on card draw, on damage taken, etc.

enum StackType {NONE, INTENSITY, DURATION, BOTH}

@export_group("Status Data")
@export var id: String
@export var type: Type
@export var stacking: StackType

@export var max_value: int = 999
@export var min_value: int = -999
@export var current_value: int: set = _set_current_value

@export var turn_stack_reduction: int = 0
@export var turn_stack_multiplier: float = 0.0
@export var can_expire: bool = true

@export_group("Status Visuals")
@export var name : String
@export var icon : Texture
@export_multiline var tooltip: String


func do_stack_reduction() -> void:
	print ("Ordered to reduce stack size!")
	current_value = floori((current_value - turn_stack_reduction) * turn_stack_multiplier)
	# in youtube version, the value reduction happens in the _on_status_applied callback found in the status handler

func initialize_status(_target: Node) -> void:
	# Called by status handler's add_status method; that handles stacking.
	pass

func _set_current_value(value: int) -> void:
	current_value = clampi(value, min_value, max_value)
	status_changed.emit()


func apply() -> void:
	status_applied.emit(self)


func get_tooltip() -> String:
	return tooltip
