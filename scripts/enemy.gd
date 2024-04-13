extends CharacterBody3D
class_name Enemy

@onready var col: CollisionShape3D = $CollisionShape3D

const GROUP: String = "enemies"

func _ready() -> void:
	add_to_group(GROUP)

func get_center() -> Vector3:
	return col.global_position
