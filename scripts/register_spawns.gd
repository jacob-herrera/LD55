extends Node

@export var room: GameCoordinator.Room

func _ready() -> void:
	GameCoordinator.register_spawns(self, room)
