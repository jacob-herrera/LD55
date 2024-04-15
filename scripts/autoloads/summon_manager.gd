extends Node
class_name SummonManager

const SUMMON_SCENES: Dictionary = {
	Summon.Type.WIZARD: preload("res://scenes/summons/wizard_summon.tscn"),
	Summon.Type.SNOWMAN: preload("res://scenes/summons/snowman_summon.tscn"),
	Summon.Type.CLERIC: preload("res://scenes/summons/cleric_summon.tscn"),
	Summon.Type.SHIELD: preload("res://scenes/summons/shield_summon.tscn")
}

var summon_preview_cache: Dictionary = {}

var temp_preview: PackedScene = preload("res://scenes/temp_preview.tscn")

func get_preview_of_summon(summon_type: Summon.Type) -> Node3D:
	return summon_preview_cache[summon_type].duplicate()

func give_player_summon(summon_type: Summon.Type) -> void:
	var summon: Summon = spawn_summon(summon_type)
	get_tree().current_scene.add_child(summon)
	globals.character.carrying = summon
	
func _ready() -> void:
	for summon_type: Summon.Type in SUMMON_SCENES:
		var scene: PackedScene = SUMMON_SCENES.get(summon_type)
		var temp_node: Node = scene.instantiate()
		if temp_node is Summon:
			var summon := temp_node as Summon
			var sprite: Sprite3D = summon.find_child("Sprite3D")
			var shadow: Sprite3D = summon.find_child("Shadow")
			var dupe_sprite = sprite.duplicate()
			var dupe_shadow = shadow.duplicate()
			var preview_node: Node3D = Node3D.new()
			preview_node.add_child(dupe_sprite)
			preview_node.add_child(dupe_shadow)
			summon.free()
			preview_node.name = Summon.TYPE_TO_STRING[summon_type] + "_preview_cache"
			summon_preview_cache[summon_type] = preview_node
			#get_tree().current_scene.add_child(preview_node)
			#preview_node.global_position = Vector3(0,0,0)
 	
func spawn_summon(summon_type: Summon.Type) -> Summon:
	#var summon_name: String = Summon.TYPE_TO_STRING[summon]
	if not SUMMON_SCENES.has(summon_type):
		printerr("invalid")
		return
	if is_instance_valid(globals.character.carrying):
		globals.character.carrying.queue_free()
	var scene: PackedScene = SUMMON_SCENES.get(summon_type)
	return scene.instantiate() as Summon

func _process(delta: float) -> void:
	var all_summons: Array[Summon] = []
	
	for node: Node in get_tree().get_nodes_in_group(Summon.GROUP):
		if node is Summon:
			all_summons.append(node)
		
	for summon: Summon in all_summons:
		summon.do_buffs()
		
	for summon: Summon in all_summons:
		summon.try_attacks(delta)
		
	for summon: Summon in all_summons:
		summon.reset_to_base()
	
