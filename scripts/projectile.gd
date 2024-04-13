extends Node3D
class_name Projectile

enum CanHit {
	ENEMY,
	SUMMON,
}


@export var trying_to_hit: CanHit
@export var dir: Vector3
@export var speed: float = 10.0

const LIFETIME: float = 8.0
var lifetime: float = LIFETIME


func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
		
	var move_delta: Vector3 = dir * speed * delta
	global_position += move_delta
