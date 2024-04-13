extends CharacterBody3D
class_name Enemy

@onready var col: CollisionShape3D = $CollisionShape3D

@export var health: int

const LAYER: int = 8
const GROUP: String = "enemies"

func _ready() -> void:
	collision_layer = LAYER
	add_to_group(GROUP)

func get_center() -> Vector3:
	return col.global_position

func take_damage(damage_taking: int) -> void:
	health -= damage_taking
	if health <= 0:
		queue_free()
