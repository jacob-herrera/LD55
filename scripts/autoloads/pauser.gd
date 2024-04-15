extends Node
class_name Pauser

static var is_paused: bool = false
var last_focus: Control

@onready var pause_menu_scene: PackedScene = preload("res://scenes/pause_menu.tscn")
var pause_menu: PauseMenu

func pause() -> void:
	if not is_paused:
		var sounds3d: Array[Node] = get_tree().get_nodes_in_group("sounds3D")
		var sounds: Array[Node] = get_tree().get_nodes_in_group("sounds")
		for player: AudioStreamPlayer3D in sounds3d:
			player.stream_paused = true
		for player: AudioStreamPlayer in sounds:
			player.stream_paused = true
		last_focus = get_viewport().gui_get_focus_owner()
		is_paused = true
		pause_menu = pause_menu_scene.instantiate()
		get_tree().root.add_child(pause_menu)
		pause_menu.name = "pause_menu"
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func unpause() -> void:
	if is_paused:
		var sounds3d: Array[Node] = get_tree().get_nodes_in_group("sounds3D")
		var sounds: Array[Node] = get_tree().get_nodes_in_group("sounds")
		for player: AudioStreamPlayer3D in sounds3d:
			player.stream_paused = false
		for player: AudioStreamPlayer in sounds:
			player.stream_paused = false
		is_paused = false
		pause_menu.queue_free()
		pause_menu = null
		if last_focus != null and last_focus.is_inside_tree():
			last_focus.grab_focus()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
