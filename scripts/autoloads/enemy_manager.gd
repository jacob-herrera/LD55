extends Node
class_name EnemyManager

const ENEMY_SCENES: Dictionary = {
	"test": preload("res://scenes/enemies/enemy.tscn"),
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
	get_tree().call_group("Enemy", "die")
	
func check_enemies() -> void:
	if get_tree().get_nodes_in_group("Enemy").is_empty():
		print("Win")
	else:
		print("Fail")
		globals.lives -= 1
		print("Lives: " + str(globals.lives))
