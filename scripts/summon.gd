extends AnimatableBody3D
class_name Summon

@onready var projectile: PackedScene = preload("res://scenes/projectile.tscn")
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var healthbar: Healthbar = $healthbar

const LAYER: int = 16
const GROUP: String = "summons"

@export_category("Base Stats")
## Attack range
@export var base_attack_range: float
## Attacks per second
@export var base_attack_rate: float
## Damage per attack
@export var base_damage: int
@export var base_max_health: int
@export var base_aoe_range: float
@export_category("Other")
@export var aoe_effects: Dictionary
@export var range_type: RangeType
enum RangeType { RANGED, MELEE }

var attack_cooldown: float

var health: int

var attack_range: float
var attack_rate: float
var damage: int
var max_health: int
var aoe_range: float

func reset_to_base() -> void:
	attack_rate = base_attack_rate
	damage = base_damage
	attack_range = base_attack_range
	max_health = base_max_health
	aoe_range = base_aoe_range
	
func _ready() -> void:
	add_to_group(Summon.GROUP)
	collision_layer = LAYER
	sync_to_physics = false
	
	reset_to_base()
	health = max_health
	attack_cooldown = 1.0 / attack_rate
	
	healthbar.initalize(max_health, col)
	
func _process(delta: float) -> void:
	reset_to_base()
	attack_cooldown -= delta
	if aoe_range > 0:
		do_buff()
	if attack_range > 0 && attack_cooldown <= 0: 
		attack_cooldown = 1.0 / attack_rate
		do_attack()
	
func get_center() -> Vector3:
	return col.global_position
	
func do_attack() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group(Enemy.GROUP)
	var enemy: Enemy = Utils.get_closest_in_range(global_position, enemies, attack_range)
	if enemy == null: return
	print(damage)
	var proj: Projectile = projectile.instantiate() as Projectile
	get_tree().current_scene.add_child(proj)
	proj.global_position = get_center()
	proj.dir = get_center().direction_to(enemy.get_center())
	proj.damage = damage
	
func do_buff() -> void:
	var allies: Array[Node] = get_tree().get_nodes_in_group(Summon.GROUP)

	var nearby: Array[Summon]
	for node: Node in allies:
		var node3d := node as Node3D
		var dist: float = global_position.distance_to(node3d.global_position)
		if dist < aoe_range:
			nearby.append(node)
	# summon currently also buffs itself, so must set summon's attack rate to 0
	
	for summ: Summon in nearby:
		summ.damage += 30
