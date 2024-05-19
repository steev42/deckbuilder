class_name StatusUI
extends TextureRect

@export var status : Status : set = set_status
@onready var counter: Label = %Counter

func set_status(new_value: Status) -> void:
	if not is_node_ready():
		await ready
	status = new_value
	texture = status.icon
	counter.visible = (status.stacking != Status.StackType.NONE)
	if not status.status_changed.is_connected(_on_status_changed):
		status.status_changed.connect(_on_status_changed)
		_on_status_changed()


func _on_status_changed() -> void:
	if not is_node_ready():
		await ready
		
	if status.current_value == 0 and status.can_expire:
		queue_free()
		return
	
	if counter.visible:
		counter.text = str(status.current_value)
