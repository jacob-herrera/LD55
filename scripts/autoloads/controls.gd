extends Node
class_name Controls

const JUMP_BUFFER: float = 4.0 / 60.0 # 4 Frame jump buffer window.
static var jump_buffer: float = 0.0
static var lock_movement: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	jump_buffer -= delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if not lock_movement:
			if not Pauser.is_paused:
				pauser.pause()
			else:
				pauser.unpause()
		else:
			if Globals.is_in_summon_ui:
				ui.exit_summon_ui()

	elif event.is_action_pressed("jump") and not Pauser.is_paused and not lock_movement:
		jump_buffer = JUMP_BUFFER
		
	elif event.is_action_pressed("summon") and not Pauser.is_paused and not Globals.is_in_shop:
		if not Globals.is_in_summon_ui:
			ui.enter_summon_ui()
		else:
			ui.exit_summon_ui()
	
static func get_jump() -> bool:
	if lock_movement or Pauser.is_paused:
		return false
	return Input.is_action_pressed("jump") or jump_buffer > 0.0

static func get_move_input() -> Vector2:
	if lock_movement:
		return Vector2.ZERO
	var digital_input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var analog_input: Vector2 = Input.get_vector("move_left_joystick", "move_right_joystick", "move_forward_joystick", "move_back_joystick")
	return (analog_input + digital_input).limit_length(1.0)

static func is_move_input() -> bool:
	if lock_movement:
		return false
	return not get_move_input().is_equal_approx(Vector2.ZERO)

static func try_pickup() -> bool:
	if lock_movement:
		return false
	return Input.is_action_just_pressed("primary_action")

# Move direction relative to camera orientation
static func get_forward(relative_to: Node3D) -> Basis:
	var move_input: Vector2 = get_move_input()
	if move_input.is_equal_approx(Vector2.ZERO):
		return Basis(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)
	var back: Vector3 = relative_to.global_basis.z
	var right: Vector3 = relative_to.global_basis.x
	back.y = 0
	right.y = 0
	back = back.normalized()
	right = right.normalized()
	var z_axis = Vector3(
		-back.x * move_input.y - right.x * move_input.x, 0,
		-back.z * move_input.y - right.z * move_input.x)
	var x_axis = Vector3(
		- right.x * move_input.y + back.x * move_input.x, 0,
		- right.z * move_input.y + back.z * move_input.x)
	return Basis(x_axis, Vector3.UP, z_axis)

