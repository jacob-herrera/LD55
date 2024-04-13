extends Node3D

var rot_x: float
var rot_y: float
var rot_z: float

func _ready() -> void:
	rot_x = randf_range(25, 50)
	if randi_range(0,1) == 0:
		rot_x *= -1;
	rot_y = randf_range(25, 50)
	if randi_range(0,1) == 0:
		rot_y *= -1;
	rot_z = randf_range(25, 50)
	if randi_range(0,1) == 0:
		rot_z *= -1;
	
func _process(delta: float) -> void:
	rotate_x(rot_x * delta)
	rotate_y(rot_y * delta)
	rotate_z(rot_z * delta)
