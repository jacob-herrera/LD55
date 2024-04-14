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

func _ready() -> void:
	collision_layer = LAYER
	add_to_group(GROUP)
	healthbar.initalize(health, col)

func _physics_process(delta: float) -> void:
	var destination: Vector3 = agent.get_next_path_position()
	#var local_destination: Vector3 = destination - global_position
	var direction: Vector3 = global_position.direction_to(destination)
	velocity = direction * move_speed
	velocity.y = -1
	move_and_slide()

func _process(delta: float) -> void:
	agent.target_position = globals.character.global_position

func get_center() -> Vector3:
	return col.global_position

func take_damage(damage_taking: int, damage_dir: Vector3) -> void:
	health -= damage_taking
	healthbar.update(health)
	if health <= 0:
		utils.death_animation(global_position, damage_dir, sprite, shadow)
		queue_free()
	
