extends AnimatableBody3D
class_name Summon

@onready var sprite: Sprite3D = $Sprite3D
@onready var shadow: Sprite3D = $Shadow
@onready var projectile: PackedScene = preload("res://scenes/projectile.tscn")
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var healthbar: Healthbar = $healthbar
@onready var hurt: AudioStreamPlayer3D = $Hurt
@onready var killed: AudioStreamPlayer3D = $Killed

const LAYER: int = 16
const GROUP: String = "summons"

enum RangeType { RANGED, MELEE }
enum Type {
	WIZARD,
	SNOWMAN,
}

const TYPE_TO_STRING: Dictionary = {
	Type.WIZARD: "wizard",
	Type.SNOWMAN: "snowman",
}

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
@export var type: Type
@export var range_type: RangeType

var attack_cooldown: float

var health: int:
	set(new_value):
		health = clampi(new_value, 0, max_health)
		if is_instance_valid(healthbar):
			healthbar.update(new_value)

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
	healthbar.initalize(max_health, col, true)
	
func get_center() -> Vector3:
	return col.global_position

func get_top() -> Vector3:
	return Utils.get_top_of_box(col)

# projectile speed must be greater than target speed, else projectile will not hit
func do_ranged() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group(Enemy.GROUP)
	var enemy: Enemy = Utils.get_closest_in_range(global_position, enemies, attack_range) as Enemy
	if enemy == null: return
	var proj: Projectile = projectile.instantiate() as Projectile
	proj.initalize(type)
	get_tree().current_scene.add_child(proj)
	proj.global_position = get_center()
	proj.dir = get_center().direction_to(get_intercept(proj.global_position, proj.speed, enemy.get_center(), enemy.velocity))
	proj.damage = damage
	
func do_explode() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group(Enemy.GROUP)
	var enemy: Enemy = Utils.get_closest_in_range(global_position, enemies, attack_range)
	if global_position.distance_to(enemy.global_position) < 1:
		# play trigger sound
		
		# wait one second
		await get_tree().create_timer(0.5).timeout
		# remove sprite from scene and play exploision sound
		# damage all enemeis in a radius
	
func do_buffs() -> void:
	if aoe_range <= 0 or aoe_effects.is_empty():
		return
	# places nearby allies in array named "nearby"
	var all_summons: Array[Node] = get_tree().get_nodes_in_group(Summon.GROUP)
	for node: Node in all_summons:
		if node is Summon:
			var other := node as Summon
			if other != self:
				var dist: float = global_position.distance_to(node.global_position)
				if dist <= aoe_range:
					for key in aoe_effects:
						var value = aoe_effects[key]
						node[key] += value

func try_attacks(delta: float) -> void:
	attack_cooldown -= delta
	if attack_range > 0 && attack_cooldown <= 0: 
		attack_cooldown = 1.0 / attack_rate
		do_ranged()


func take_damage(damage_taking: int, damage_dir: Vector3) -> void:
	health -= damage_taking
	hurt.play()
	if health <= 0:
		#killed.play()
		utils.death_animation(global_position, damage_dir, sprite)
		queue_free()

	
func get_intercept(attacker_pos : Vector3,
					proj_vel : float,
					target_pos : Vector3,
					target_vel : Vector3) -> Vector3:
	var a : float = proj_vel * proj_vel - target_vel.dot(target_vel)
	var b : float = 2 * target_vel.dot(target_pos-attacker_pos)
	var c : float = (target_pos - attacker_pos).dot(target_pos - attacker_pos)
	var time : float = 0.0
	if proj_vel > target_vel.length():
		time = (b + sqrt(b * b + 4 * a * c)) / (2 * a)
	return target_pos + time * target_vel
