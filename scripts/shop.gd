extends Node
@export var cameras: Array[PhantomCamera3D]

var current_item = 0
var in_shop = false
var in_area: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if in_shop == true:
		if Input.is_action_just_pressed("ui_right"):
			cameras[current_item].set_priority(0)
			current_item += 1
			current_item = current_item % cameras.size()
			cameras[current_item].set_priority(20)
		if Input.is_action_just_pressed("ui_left"):
			cameras[current_item].set_priority(0)
			current_item -= 1
			current_item = current_item % cameras.size()
			cameras[current_item].set_priority(20)
		if Input.is_action_just_pressed("ui_cancel"):
			exit_shop()
			
func exit_shop() -> void:
	for cam: PhantomCamera3D in cameras:
		cam.set_priority(0)
	Controls.lock_movement = false
	in_shop = false
	
func _on_area_3d_body_entered(_body: Node3D):
	if in_area == false:
		in_area = true
		in_shop = true
		Controls.lock_movement = true
		cameras[0].set_priority(20)
		current_item = 0
	
func _on_area_3d_body_exited(_body: Node3D):
	in_area = false
	if in_shop:
		if GameCoordinator.state == GameCoordinator.GameState.COMBAT:
			globals.character.camera.tween_parameters.duration = 0
		exit_shop()
