extends CharacterBody3D
class_name Enemy

const GROUP: String = "enemies"

func _ready() -> void:
	add_to_group(GROUP)
