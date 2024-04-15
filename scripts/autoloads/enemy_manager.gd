extends Node
class_name EnemyManager

static var current_room_max_enemies: int = 0
static var current_room_remaining_enemies: int = 0

const ENEMY_SCENES: Dictionary = {
	"test": preload("res://scenes/enemies/enemy.tscn"),
	"basic": preload("res://scenes/enemies/basic.tscn"),
	"strong": preload("res://scenes/enemies/strong.tscn")
}

func spawn_enemy(enemy_name: String, pos: Vector3) -> void:
	if not ENEMY_SCENES.has(enemy_name):
		printerr("invalid summon name: ", enemy_name)
		return
	var scene: PackedScene = ENEMY_SCENES.get(enemy_name)
	var enemy: Enemy = scene.instantiate() as Enemy
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = pos

func remove_enemies() -> void:
	get_tree().call_group(Enemy.GROUP, "queue_free")
	
func recalc_remaining_enemies():
	EnemyManager.current_room_remaining_enemies = \
	 get_tree().get_nodes_in_group(Enemy.GROUP).size()
	
func check_enemies() -> void:
	if not GameCoordinator.wave_cleared:
		globals.lives -= 1
