extends Node
class_name Utils

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

static func get_closest_in_range(to: Vector3, nodes: Array[Node], aoe_range: float) -> Node3D:
	var closest: Node3D
	var closest_distance: float = 1000000.0
	for node: Node in nodes:
		if node is Node3D:
			var node3d := node as Node3D
			var dist: float = to.distance_to(node3d.global_position)
			if dist < aoe_range and dist < closest_distance:
				closest = node3d
	return closest

static func get_top_of_box(col: CollisionShape3D) -> Vector3:
	if not (col.shape is BoxShape3D):
		printerr("Only works for box colliders.")
		return Vector3.ZERO
	var box := col.shape as BoxShape3D
	var y_offset: float = box.size.y / 2
	return col.global_position + Vector3(0, y_offset, 0)
