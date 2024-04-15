extends Node3D
class_name Utils

var gold_dmg_display: PackedScene = preload("res://scenes/gold_dmg_display.tscn") 

func death_animation(origin: Vector3, dir: Vector3, sprite: Sprite3D) -> void:
	var node_death: Node3D = Node3D.new()
	node_death.set_script(load("res://scripts/ragdoll_projectile.gd"))
	get_tree().current_scene.add_child(node_death)
	node_death.dir = dir
	node_death.name = "DeathAnimation"
	var sprite_clone: Sprite3D = sprite.duplicate() as Sprite3D
	sprite_clone.set_script(load("res://scripts/random_spinning.gd"))
	node_death.add_child(sprite_clone)
	sprite_clone.position = sprite.position
	node_death.global_position = origin
	sprite_clone.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	
func death_noise(pos: Vector3, is_summon: bool) -> void:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.transform.origin = pos
	if is_summon:
		player.stream = load("res://assets/audio/summon_death.mp3")
	else:
		player.stream = load("res://assets/audio/drop_coins.mp3")
	get_tree().current_scene.add_child(player)
	player.play()
	
func spawn_number(sprite_loc: Vector3, is_gold: bool, val: int) -> void:
	var label: Label3D = gold_dmg_display.instantiate() as Label3D
	get_tree().current_scene.add_child(label)
	label.global_position = sprite_loc
	if is_gold:
		label.global_position.y += 0.4
		label.text = "$"+str(val)
		label.modulate = Color("ffff00")
		label.outline_modulate = Color("7a6700")
	else:
		label.text = str(val)
		label.modulate = Color("ff0000")
		label.outline_modulate = Color("190000")

	await get_tree().create_timer(0.5).timeout
	label.queue_free()

static func get_closest_in_range(to: Vector3, nodes: Array[Node], aoe_range: float) -> Node3D:
	var closest: Node3D
	var closest_distance: float = 1000000.0
	for node: Node in nodes:
		if node is Node3D:
			var node3d := node as Node3D
			var dist: float = to.distance_to(node3d.global_position)
			if dist < aoe_range and dist < closest_distance:
				closest = node3d
				closest_distance = dist
	return closest

const HEALTH_BAR_OFFSET: Vector3 = Vector3(0, 0.1, 0)
static func get_top_of_box(col: CollisionShape3D) -> Vector3:
	if col.shape is BoxShape3D:
		var box := col.shape as BoxShape3D
		var y_offset: float = box.size.y / 2.0
		return col.global_position + Vector3(0, y_offset, 0) + HEALTH_BAR_OFFSET
	elif col.shape is SphereShape3D:
		var sphere := col.shape as SphereShape3D
		var y_offset: float = sphere.radius
		return col.global_position + Vector3(0, y_offset, 0) + HEALTH_BAR_OFFSET
	elif col.shape is CapsuleShape3D:
		var cap := col.shape as CapsuleShape3D
		var y_offset: float = cap.height / 2.0
		return col.global_position + Vector3(0, y_offset, 0) + HEALTH_BAR_OFFSET
		
	printerr("Shape not supported")
	return Vector3.ZERO
