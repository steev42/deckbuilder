class_name StatusHandler
extends HBoxContainer

signal statuses_applied(type: Status.Type)

const STATUS_APPLY_INTERVAL := 0.25 # seconds between updates for visual discernment
const STATUS_UI = preload("res://scenes/ui/status_ui.tscn")

@export var status_owner : Combatant

func apply_statuses_by_type(type: Status.Type) -> void:
	if type == Status.Type.EVENT_BASED:
		# TODO Do we need to check this later?  Probably not, anything
		# in this type should check events in their own code.
		return
		
	var status_queue: Array[Status] = _get_all_statuses().filter(
		func(status:Status):
			return status.type == type
	)
	
	if status_queue.is_empty():
		statuses_applied.emit(type)
		return
	
	var tween := create_tween()
	for status: Status in status_queue:
		tween.tween_callback(status.apply_status.bind(status_owner))
		tween.tween_interval(STATUS_APPLY_INTERVAL)
	
	tween.finished.connect(func(): statuses_applied.emit(type))


func add_status(status: Status) -> void:
	# check stack type
	var stackable := (status.stacking != Status.StackType.NONE)
	
	# add if it is new
	if not _has_status(status.id):
		var status_icon = STATUS_UI.instantiate() as StatusUI
		add_child(status_icon)
		status_icon.status = status
		status_icon.status.status_applied.connect(_on_status_applied)
		status_icon.status.initialize_status(status_owner)
	
	# if it can't stack and we're trying to add, just return
	# TODO Why are we checking can_expire here? Not stackable implies that it can't expire?
	if not status.can_expire and not stackable:
		return
		
	# if it stacks, add the new value
	else:
		_get_status(status.id).current_value += status.current_value
		return


func _has_status(id: String) -> bool:
	for status_ui: StatusUI in get_children():
		if status_ui.status.id == id:
			return true
	return false
	

func _get_status(id: String) -> Status:
	for status_ui: StatusUI in get_children():
		if status_ui.status.id == id:
			return status_ui.status
	return null
	

func _get_all_statuses() -> Array[Status]:
	var statuses : Array[Status] = []
	for status_ui: StatusUI in get_children():
		statuses.append(status_ui.status)
	return statuses


func _on_status_applied(status: Status) -> void:
	if status.can_expire:
		status.do_stack_reduction()


func _on_gui_input(event: InputEvent) -> void:
	# Show tooltip when pressed?  When hovered?
	pass
