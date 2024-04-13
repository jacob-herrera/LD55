extends AnimatableBody3D
class_name Summon

@onready var projectile: PackedScene = preload("res://scenes/projectile.tscn")
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var healthbar: Healthbar = $healthbar

const LAYER: int = 16
const GROUP: String = "summons"

## Attack range
@export var range: float
## Attacks per second
@export var attack_rate: float
## Damage per attack
@export var damage: int
@export var health: int
@export var range_type: RangeType
enum RangeType { RANGED, MELEE }

func _ready() -> void:
	add_to_group(Summon.GROUP)
	collision_layer = LAYER
	sync_to_physics = false
	healthbar.initalize(health, col)
	
func _process(delta: float) -> void:
	attack_cooldown -= delta
	if attack_cooldown <= 0: 
		attack_cooldown = 1.0 / attack_rate
		do_attack()
	
func get_center() -> Vector3:
	return col.global_position
	
var attack_cooldown: float = 0.0
	
func do_attack() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group(Enemy.GROUP)
	var enemy: Enemy = Utils.get_closest_in_range(global_position, enemies, range)
	if enemy == null: return
	
	#var enemy: Enemy = enemies[0] as Enemy
	var proj: Projectile = projectile.instantiate() as Projectile
	get_tree().current_scene.add_child(proj)
	proj.global_position = get_center()
	proj.dir = get_center().direction_to(enemy.get_center())
	proj.damage = damage
	

	
	

	
