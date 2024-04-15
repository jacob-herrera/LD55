extends Sprite3D
class_name Projectile

enum CanHit {
	ENEMY,
	SUMMON,
}

@export var fireball_texture: CompressedTexture2D
@export var snowball_texture: CompressedTexture2D
@export var arrow_texture: CompressedTexture2D
@export var trying_to_hit: CanHit
@export var dir: Vector3
@export var speed: float = 10.0 # Default to 10 units per second
@export var damage: int

@export var hitbox: SphereShape3D

const LIFETIME: float = 4.0
var lifetime: float = LIFETIME

var space_state: PhysicsDirectSpaceState3D 

func _ready() -> void:
	space_state = PhysicsServer3D.space_get_direct_state(get_world_3d().space)
	
func initalize(value : int) -> void:
	if value == 1:
		texture = snowball_texture
	else:
		texture = fireball_texture
	

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
		
	var move_delta: Vector3 = dir * speed * delta
	global_position += move_delta	

	try_to_hit()

func try_to_hit() -> void:
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = hitbox
	params.transform = global_transform
	params.collision_mask = Enemy.LAYER
	var results: Array[Dictionary] = space_state.intersect_shape(params)
	for result: Dictionary in results:
		if result.collider is Enemy:
			var enemy: Enemy = result.collider as Enemy
			enemy.take_damage(damage, dir)
			queue_free()
		else:
			printerr("Collider, " + result.collider.name + " in enemy layer without being an Enemy")
