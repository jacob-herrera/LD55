extends Area3D

@onready var mana_sound: AudioStreamPlayer3D = $"ManaPickup"
@onready var enter_sound: AudioStreamPlayer3D = $EnterPool

const TIME: float = 0.25 # Every one second
var time: float = 0.0
var is_in_pool: bool = false
var was_in_pool: bool = false

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
				if Globals.mana < Globals.max_mana:
					Globals.mana += 1
				is_in_pool = true
			elif body is Summon:
				var summon: Summon = body as Summon
				if summon.health < summon.max_health:
					summon.health += 1
		if is_in_pool:
			if !was_in_pool:
				enter_sound.play()
			was_in_pool = true
			play_mana()
		else:
			mana_sound.stop()
			was_in_pool = false

func play_mana() -> void:
	if !mana_sound.playing &&  Globals.mana != Globals.max_mana:
		mana_sound.play()
