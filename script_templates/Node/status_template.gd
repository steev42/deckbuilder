#meta-name: Status
#meta-description Create a status which can be applied to a target
class_name PlaceholderStatus
extends Status

var member_var := 0

func initialize_status(_target: Node) -> void:
	pass


func apply() -> void:
	status_applied.emit(self)


func get_tooltip() -> String:
	return tooltip
