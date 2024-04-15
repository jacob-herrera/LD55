extends Node
class_name SummonManager

const SUMMON_SCENES: Dictionary = {
	"wizard": preload("res://scenes/summons/wizard_summon.tscn"),
	"snowman": preload("res://scenes/summons/snowman_summon.tscn")
}

var temp_preview: PackedScene = preload("res://scenes/temp_preview.tscn")

func get_preview_of_summon(summon: Summon.Type) -> Node3D:
	return temp_preview.instantiate() as Node3D

func give_player_summon(summon_name: String) -> void:
	if not SUMMON_SCENES.has(summon_name):
		printerr("invalid summon name: ", summon_name)
		return
	if is_instance_valid(globals.character.carrying):
		globals.character.carrying.queue_free()
	var scene: PackedScene = SUMMON_SCENES.get(summon_name)
	var inst: Node3D = scene.instantiate() 
	get_tree().current_scene.add_child(inst)
	globals.character.carrying = inst
