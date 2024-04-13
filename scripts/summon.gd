extends Node3D
class_name Summon

@onready var projectile: PackedScene = preload("res://scenes/projectile.tscn")

const GROUP: String = "summons"

## Attack range
@export var range: float
## Attacks per second
@export var attack_rate: float
## Damage per attack
@export var damage: int
@export var health: int
@export var range_type: RangeType

enum RangeType {
	PROJECTILE,
	MELEE,
}

func _ready() -> void:
	add_to_group(Summon.GROUP)
	
var attack_cooldown: float = 0.0
	
func do_attack() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group(Enemy.GROUP)
	# TODO get closest enemy
	var enemy: Enemy = enemies[0] as Enemy
	var proj: Projectile = projectile.instantiate() as Projectile
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position
	proj.dir = global_position.direction_to(enemy.global_position)
	
	
func _process(delta: float) -> void:
	attack_cooldown -= delta
	if attack_cooldown <= 0: 
		attack_cooldown = 1.0 / attack_rate
		do_attack()
	
	
	

	
