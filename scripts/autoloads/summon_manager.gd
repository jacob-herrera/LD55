extends Node
class_name SummonManager

const SUMMON_SCENES: Dictionary = {
	"wizard": preload("res://scenes/summons/wizard_summon.tscn"),
	"snowman": preload("res://scenes/summons/snowman_summon.tscn")
}

var temp_preview: PackedScene = preload("res://scenes/temp_preview.tscn")

func get_preview_of_summon(_summon: Summon.Type) -> Node3D:
	return temp_preview.instantiate() as Node3D

func give_player_summon(summon_type: Summon.Type) -> void:
	var summon: Summon = spawn_summon(summon_type)
	get_tree().current_scene.add_child(summon)
	globals.character.carrying = summon
	
func spawn_summon(summon: Summon.Type) -> Summon:
	var summon_name: String = Summon.TYPE_TO_STRING[summon]
	if not SUMMON_SCENES.has(summon_name):
		printerr("invalid summon name: ", summon_name)
		return
	if is_instance_valid(globals.character.carrying):
		globals.character.carrying.queue_free()
	var scene: PackedScene = SUMMON_SCENES.get(summon_name)
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
	
