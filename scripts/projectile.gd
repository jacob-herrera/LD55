extends Node3D
class_name Projectile

enum CanHit {
	ENEMY,
	SUMMON,
}

@export var trying_to_hit: CanHit
@export var dir: Vector3
@export var speed: float = 10.0 # Default to 10 units per second
@export var damage: int

const LIFETIME: float = 8.0
var lifetime: float = LIFETIME

var space_state: PhysicsDirectSpaceState3D 

func _ready() -> void:
	space_state = PhysicsServer3D.space_get_direct_state(get_world_3d().space)

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
		
	var move_delta: Vector3 = dir * speed * delta
	global_position += move_delta

	try_to_hit()

func try_to_hit() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group(Enemy.GROUP)
	var params := PhysicsPointQueryParameters3D.new()
	params.position = global_position
	params.collision_mask = Enemy.LAYER
	var results: Array[Dictionary] = space_state.intersect_point(params)
	for result: Dictionary in results:
		if result.collider is Enemy:
			var enemy: Enemy = result.collider as Enemy
			enemy.take_damage(damage, dir)
			queue_free()
		else:
			printerr("Collider, " + result.collider.name + " in enemy layer without being an Enemy")
