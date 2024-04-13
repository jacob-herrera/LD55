extends Area3D

const TIME: float = 0.25 # Every one second
var time: float = 0.0

func _ready() -> void:
	collision_mask = Character.LAYER | Summon.LAYER

func _process(delta: float) -> void:
	time -= delta
	if time <= 0:
		time = TIME
		var bodies: Array[Node3D] = get_overlapping_bodies()
		for body: Node3D in bodies:
			if body is Character:
				Globals.mana += 1
			if body is Summon:
				var summon: Summon = body as Summon
				summon.health += 1
			
