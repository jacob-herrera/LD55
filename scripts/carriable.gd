extends Node
class_name Carriable

const GROUP: String = "carriables"

func _ready() -> void:
	get_parent().add_to_group(GROUP)
