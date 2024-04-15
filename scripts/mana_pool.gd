extends Area3D

@onready var mana_sound: AudioStreamPlayer3D = $ManaPickup
@onready var enter_sound: AudioStreamPlayer3D = $EnterPool
@onready var mana_full: AudioStreamPlayer3D = $ManaFull

const TIME: float = 0.25 # Every one second
var time: float = 0.0
var isFull = false
var shouldReplay = true

func _ready() -> void:
	collision_mask = Character.LAYER | Summon.LAYER
	mana_sound.set_loop(true)

var was_in_area_last_frame: bool = false

func _process(delta: float) -> void:
	
	var is_in_area_this_frame: bool = false
	var bodies: Array[Node3D] = get_overlapping_bodies()
	
	for body: Node3D in bodies:
		if body is Character:
			if not was_in_area_last_frame:
				enter_sound.play()
				mana_sound.play()
			is_in_area_this_frame = true
	
	if is_in_area_this_frame and Globals.mana < Globals.max_mana and shouldReplay:
		mana_sound.play()
		shouldReplay = false
		
	if Globals.mana == Globals.max_mana:
		mana_sound.stop()
		shouldReplay = true
		if isFull:
			mana_full.play()
			isFull = false
	
	if not is_in_area_this_frame and was_in_area_last_frame:
		mana_sound.stop()
		shouldReplay = true
	
	was_in_area_last_frame = is_in_area_this_frame
	
		
	time -= delta
	if time <= 0:
		time = TIME
		for body: Node3D in bodies:
			if body is Character:
				if Globals.mana < Globals.max_mana:
					if Globals.mana + 1 >= Globals.max_mana:
						isFull = true
					Globals.mana += 1
			elif body is Summon:
				var summon: Summon = body as Summon
				if summon.health < summon.max_health:
					summon.health += 1
					
