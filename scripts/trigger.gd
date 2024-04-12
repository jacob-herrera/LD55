extends Area3D

@export var func_godot_properties: Dictionary

func _ready() -> void:
	body_entered.connect(_on_body_enter)

func _on_body_enter(body: Node3D) -> void:
	if func_godot_properties.has("map"):
		var map: String = func_godot_properties.get("map") as String
		if map != null:
			map_changer.change_map(map)
