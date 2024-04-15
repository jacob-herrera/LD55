extends Node3D

@export var room: GameCoordinator.Room

func _ready() -> void:
	GameCoordinator.register_room(self, room)
