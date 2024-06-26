extends CharacterBody3D
class_name Enemy

@onready var col: CollisionShape3D = $CollisionShape3D
@onready var sprite: Sprite3D = $Sprite3D
@onready var shadow: Sprite3D = $Shadow
@onready var healthbar: Healthbar = $healthbar
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var hurt: AudioStreamPlayer3D = $Hurt
@onready var drop: AudioStreamPlayer3D = $DropCoins
@export var healthbar_offset: float

@export var max_health: int
@export var move_speed: float
@export var attack_range: float
@export var attack_rate: float
@export var attack_damage: int

@export var gold_value: int

const LAYER: int = 8
const GROUP: String = "enemies"
const GRAVITY: float = -1
const SUMMON_SEARCH_RADIUS: float = 25.0
const LOS_LAYER: int = Globals.GROUND_LAYER | Character.LAYER

static var space_state: PhysicsDirectSpaceState3D
var attack_cooldown: float = 0.0
var health: int:
	set(new_value):
		health = clampi(new_value, 0, max_health)
		if is_instance_valid(healthbar):
			healthbar.update(new_value)

var is_naving: bool = false

func _ready() -> void:
	collision_layer = LAYER
	add_to_group(GROUP)
	health = max_health
	var top: Vector3 = Utils.get_top_of_box(col) + Vector3(0, healthbar_offset, 0)
	healthbar.initalize(health, top, false)
	if space_state == null:
		space_state = PhysicsServer3D.space_get_direct_state(get_world_3d().space)
	agent.velocity_computed.connect(_on_velocity_compute)
	#set_physics_process(false)
	#call_deferred("navigation_setup")
#
#func _on_map_changed(_rid: RID):
	#set_physics_process(true)
	#NavigationServer3D.map_changed.disconnect(_on_map_changed)
#
#func navigation_setup():
	#NavigationServer3D.map_changed.connect(_on_map_changed)

func try_do_damage(target_summon: Summon) -> void:
	if attack_cooldown <= 0:
		attack_cooldown = 1.0 / attack_rate
		var distance: float = global_position.distance_to(target_summon.global_position)
		if distance <= attack_range:
			var dir: Vector3 = global_position.direction_to(target_summon.global_position)
			target_summon.take_damage(attack_damage, dir)
	
func _on_velocity_compute(safe_velocity: Vector3) -> void:
	if is_naving:
		velocity = safe_velocity
		move_and_slide()
	
func _physics_process(delta: float) -> void:
	var target: Vector3 = Vector3.ZERO
	# Look for target
	var summons: Array[Node] = get_tree().get_nodes_in_group(Summon.GROUP)
	var summon: Summon = Utils.get_closest_in_range(global_position, summons, SUMMON_SEARCH_RADIUS)
	if summon != null:
		target = summon.global_position
	else:
		target = globals.character.global_position
	
	var direction: Vector3 = Vector3.ZERO
	
	# If a summon was found in range. 
	if not target.is_equal_approx(Vector3.ZERO):	
		# Try going to target
		var has_highground: bool = target.y - global_position.y < -0.5
		
		if has_highground: # Try direct path
			var from: Vector3 = global_position
			var to: Vector3 = target
			var query := PhysicsRayQueryParameters3D.create(from, to, LOS_LAYER)
			var result: Dictionary = space_state.intersect_ray(query)
			if not result.is_empty() and result.collider is Character:
				direction = global_position.direction_to(target)
			velocity = Vector3(direction.x * move_speed, velocity.y + GRAVITY, direction.z * move_speed)
			move_and_slide()
			is_naving = false
			
		if direction == Vector3.ZERO: # Just pathfind
			agent.target_position = target
			var destination: Vector3 = agent.get_next_path_position()
			direction = global_position.direction_to(destination)
			var goal_velocity = Vector3(direction.x * move_speed, velocity.y + GRAVITY, direction.z * move_speed)
			if is_on_floor():
				goal_velocity.y = 0
			agent.velocity = goal_velocity
			is_naving = true
	else:
		velocity = Vector3(0, velocity.y + GRAVITY, 0)
		move_and_slide()
		is_naving = false
	
	if summon != null:
		attack_cooldown -= delta
		try_do_damage(summon)

func get_center() -> Vector3:
	return col.global_position

func get_top() -> Vector3:
	return Utils.get_top_of_box(col)

func take_damage(damage_taking: int, damage_dir: Vector3) -> void:
	health -= damage_taking
	utils.spawn_number(get_top(), false, damage_taking)
	hurt.play()
	if health <= 0:
		utils.death_noise(global_position, false)
		Globals.coins += gold_value
		utils.death_animation(global_position, damage_dir, sprite)
		utils.spawn_number(get_top(), true, gold_value)
		queue_free()

