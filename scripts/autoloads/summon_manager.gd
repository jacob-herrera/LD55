extends Node
class_name SummonManager

const SUMMON_SCENES: Dictionary = {
	"wizard": preload("res://summons/wizard_summon.tscn"),
	"snowman": preload("res://summons/snowman_summon.tscn")
}

func give_player_summon(summon_name: String) -> void:
	if not SUMMON_SCENES.has(summon_name):
		printerr("invalid summon name: ", summon_name)
		return
	if globals.character.carrying:
		globals.character.carrying.queue_free()
	var scene: PackedScene = SUMMON_SCENES.get(summon_name)
	var inst: Node3D = scene.instantiate() 
	get_tree().current_scene.add_child(inst)
	globals.character.carrying = inst
