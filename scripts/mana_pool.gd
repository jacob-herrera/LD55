extends Area3D

@onready var mana_sound = $mana_pickup_sound

const TIME: float = 0.25 # Every one second
var time: float = 0.0
var is_in_pool: bool = false

func _ready() -> void:
	collision_mask = Character.LAYER | Summon.LAYER

func _process(delta: float) -> void:
	time -= delta
	if time <= 0:
		time = TIME
		var bodies: Array[Node3D] = get_overlapping_bodies()
		is_in_pool = false
		for body: Node3D in bodies:
			if body is Character:
				Globals.mana += 1
				is_in_pool = true
				play_mana()
			elif body is Summon:
				var summon: Summon = body as Summon
				summon.health += 1
		if is_in_pool == false:
			mana_sound.stop()
				

func play_mana() -> void:
	if !mana_sound.playing:
		mana_sound.play()
