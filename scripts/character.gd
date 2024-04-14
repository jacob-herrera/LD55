extends CharacterBody3D
class_name Character

@onready var main_sprite: Sprite3D = $MainSprite
@onready var jump_sprite: Sprite3D = $JumpSprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var summon_circle: SummonCircle = $summon_circle
@onready var summon_pickup: AudioStreamPlayer3D = $SummonPickup
@onready var summon_place: AudioStreamPlayer3D = $SummonPlace
@onready var footsteps: AudioStreamPlayer3D = $Footsteps
@onready var jump: AudioStreamPlayer3D = $Jump
@export_flags_3d_physics var ground_layer: int
@export var camera: PhantomCamera3D

const LAYER: int = 4

var carrying: Node3D
const CARRY_SPEED_SLOW: float = 0.7


const CHAR_SPEED: float = 5.0
const ACCEL: float = 100.0
const STOP_ACCEL: float = 15.0
const GRAV: float = -1.0
const JUMP: float = 13.0

const JUMP_SPIN_SPEED: float = 40.0

const COYOTE_TIME: float = 5.0 / 60.0
var coyote_time: float = 0.0

var last_direction: Direction
var last_heading: Vector3
var jumped: bool = false

var rot: float = 0

enum Direction {
	NORTH_EAST, NORTH, NORTH_WEST,
	EAST,
	SOUTH_EAST, SOUTH, SOUTH_WEST,
	WEST,
}

const DIRECTION_TO_STRING: Dictionary = {
	Direction.NORTH: "north",
	Direction.NORTH_EAST: "north_east",
	Direction.EAST: "east",
	Direction.SOUTH_EAST: "south_east",
	Direction.SOUTH: "south",
	Direction.SOUTH_WEST: "south_west",
	Direction.WEST: "west",
	Direction.NORTH_WEST: "north_west"
}

static func vec_to_direction(vec: Vector2) -> Direction:
	var angle: float = rad_to_deg(vec.angle_to(Vector2.UP))
	if -22.5 < angle and angle < 22.5:
		return Direction.NORTH
	elif 22.5 < angle and angle < 67.5:
		return Direction.NORTH_WEST
	elif 67.5 < angle and angle < 112.5:
		return Direction.WEST
	elif 112.5 < angle and angle < 157.5:
		return Direction.SOUTH_WEST
	elif -67.5 < angle and angle < -22.5:
		return Direction.NORTH_EAST
	elif -112.5 < angle and angle < -67.5:
		return Direction.EAST
	elif -157.5 < angle and angle < -112.5:
		return Direction.SOUTH_EAST
	else:
		return Direction.SOUTH

func _ready() -> void:
	globals.character = self
	last_heading = jump_sprite.global_basis.z
	collision_layer = LAYER
	camera.set_priority(10)

func  _process(delta: float) -> void:
	rot += delta * JUMP_SPIN_SPEED if jumped else 0.0

func _physics_process(delta: float) -> void:
	if Pauser.is_paused or Controls.lock_movement: return
	
	var change: Vector3

	if Controls.is_move_input():
		var heading: Basis = Controls.get_forward(camera)
		var speed: float = CHAR_SPEED * CARRY_SPEED_SLOW if carrying != null else CHAR_SPEED
		var target_velocity: Vector3 = -heading.z * speed
		var flat_velocity: Vector3 = Vector3(velocity.x, 0, velocity.z)
		var needed_accel: Vector3 = (target_velocity - flat_velocity) / delta
		needed_accel = needed_accel.limit_length(ACCEL)
		last_heading = -heading.z
		last_direction = Character.vec_to_direction(Controls.get_move_input())
		anim_player.play("walk_" + DIRECTION_TO_STRING[last_direction])
		change = needed_accel * delta
		play_footsteps()
	else:
		var needed_accel: Vector3 = -velocity / delta
		needed_accel = needed_accel.limit_length(STOP_ACCEL)
		anim_player.play("idle_" + DIRECTION_TO_STRING[last_direction])
		change = needed_accel * delta
		footsteps.stop()
	velocity = velocity + change
	
	var dir_basis: Basis = Basis.looking_at(last_heading, Vector3.UP, true)
	var final_basis = dir_basis.rotated(dir_basis.x, rot) # Add jump spin.
	jump_sprite.global_basis = final_basis
	
	var grounded: bool = coyote_time > 0.0 or is_on_floor()
	if Controls.get_jump() and grounded and carrying == null:
		print(carrying == null)
		velocity.y = JUMP
		jumped = true
		Controls.jump_buffer = 0.0
		coyote_time = 0.0
		jump.play()
		footsteps.stop()
	else:	
		if not is_on_floor():
			coyote_time -= delta
			if coyote_time < 0.0:
				velocity.y += GRAV
				if jumped:
					main_sprite.visible = false
					jump_sprite.visible = true
			else:
				velocity.y = 0
		else:
			main_sprite.visible = true
			jump_sprite.visible = false
			velocity.y = 0
			jumped = false
			coyote_time = COYOTE_TIME
		
	move_and_slide()
	do_carry()
		
func do_carry() -> void:
	if carrying == null:
		var carriables: Array[Node] = get_tree().get_nodes_in_group(Carriable.GROUP)
		var closest: Node3D = Utils.get_closest_in_range(global_position, carriables, 1.0)
		if Controls.try_pickup() and closest != null:
			carrying = closest
			summon_pickup.play()
	elif carrying != null:
		carrying.global_position = global_position + Vector3(0, 0.7 ,0)
		if Controls.try_pickup():
			# raycast to floor
			var space_rid := get_world_3d().space
			var space_state := PhysicsServer3D.space_get_direct_state(space_rid)
			var from: Vector3 = global_position + Vector3(0, 1, 0)
			var to: Vector3 = global_position - Vector3(0, 100, 0)
			var query := PhysicsRayQueryParameters3D.create(from, to, ground_layer)
			var result = space_state.intersect_ray(query)
			if not result.is_empty():
				carrying.position = result.position
				carrying = null
				summon_place.play()
				
func play_footsteps() -> void:
	if !footsteps.playing && is_on_floor():
		footsteps.play()
