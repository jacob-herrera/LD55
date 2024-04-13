extends Node
class_name Utils

#var spin_script: Script = 

func death_animation(origin: Vector3, dir: Vector3, sprite: Sprite3D, shadow: Decal) -> void:
	var node_death: Node3D = Node3D.new()
	node_death.set_script(load("res://scripts/ragdoll_projectile.gd"))
	get_tree().current_scene.add_child(node_death)
	node_death.dir = dir
	node_death.name = "DeathAnimation"
	var sprite_clone: Sprite3D = sprite.duplicate() as Sprite3D
	sprite_clone.set_script(load("res://scripts/random_spinning.gd"))
	var shadow_clone: Decal = shadow.duplicate() as Decal
	node_death.add_child(sprite_clone)
	node_death.add_child(shadow_clone)
	sprite_clone.position = sprite.position
	shadow_clone.position = shadow.position
	node_death.global_position = origin
	sprite_clone.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	pass
