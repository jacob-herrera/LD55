extends CharacterBody3D
class_name Enemy

@onready var col: CollisionShape3D = $CollisionShape3D
@onready var sprite: Sprite3D = $Sprite3D
@onready var shadow: Decal = $Shadow
@onready var healthbar: Healthbar = $healthbar
@onready var agent: NavigationAgent3D = $NavigationAgent3D

@export var health: int
@export var move_speed: float = 2

const LAYER: int = 8
const GROUP: String = "enemies"

const GRAVITY: float = -1
static var space_state: PhysicsDirectSpaceState3D 

const LOS_LAYER: int = Globals.GROUND_LAYER | Character.LAYER

func _ready() -> void:
	collision_layer = LAYER
	add_to_group(GROUP)
	healthbar.initalize(health, col)
	if space_state == null:
		space_state = PhysicsServer3D.space_get_direct_state(get_world_3d().space)
	set_physics_process(false)
	call_deferred("navigation_setup")

func _on_map_changed(_rid: RID):
	set_physics_process(true)
	NavigationServer3D.map_changed.disconnect(_on_map_changed)

func navigation_setup():
	NavigationServer3D.map_changed.connect(_on_map_changed)

func _physics_process(_delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO
	var target: Vector3 = globals.character.global_position
	var has_highground: bool = target.y - global_position.y < -0.5
	
	if has_highground: # Try direct path
		var from: Vector3 = global_position
		var to: Vector3 = target
		var query := PhysicsRayQueryParameters3D.create(from, to, LOS_LAYER)
		var result: Dictionary = space_state.intersect_ray(query)
		if not result.is_empty() and result.collider is Character:
			direction = global_position.direction_to(target)
	if direction == Vector3.ZERO: # Just pathfind
		agent.target_position = globals.character.global_position
		var destination: Vector3 = agent.get_next_path_position()
		direction = global_position.direction_to(destination)
		
	velocity = Vector3(direction.x * move_speed, velocity.y + GRAVITY, direction.z * move_speed)
	if is_on_floor():
		velocity.y = 0

	move_and_slide()


func get_center() -> Vector3:
	return col.global_position

func take_damage(damage_taking: int, damage_dir: Vector3) -> void:
	health -= damage_taking
	healthbar.update(health)
	if health <= 0:
		utils.death_animation(global_position, damage_dir, sprite, shadow)
		queue_free()
	
