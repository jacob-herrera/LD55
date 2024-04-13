extends Node3D

var dir: Vector3 = Vector3(0, 0, -1)
var y_vel: float = 10.0
const FLAT_SPEED: float = 10.0
const GRAV: float = -25.0

func _process(delta: float) -> void:
	var flat_dir: Vector3 = Vector3(dir.x, 0, dir.z).normalized()
	var flat_vel: Vector3 = flat_dir * FLAT_SPEED
	y_vel += GRAV * delta
	var vel: Vector3 = Vector3(flat_vel.x, y_vel, flat_vel.z)
	global_position += vel * delta
	if global_position.y < -1:
		queue_free()
