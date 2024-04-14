extends Node
class_name GameCoordinator

@onready var fill: ColorRect = $CanvasLayer/BlackFill
@onready var anim_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

enum Room {
	HUB,
	ROOM_1,
}

const ROOM_HUB_TELE := Vector3(0,0,0)
const ROOM_1_TELE := Vector3(32, 0, 0)

const PLAYER_CAMERA_DEFAULT_TWEEN: float = 0.5
const FADE_DURATION: float = 10.0 / 30.0
const PLAYER_SUMMON_DURATION = 6.0

const HUB_TIME: float = 30.0
const COMBAT_TIME: float = 60.0

const ROOM_MULTI_TEMP: float = 2.0 #REPLACE THIS WHEN ROOM MULTIPLIERS CALCS ARE SET UP

static var current_room: Room = Room.HUB
static var current_round: int = 0
static var time: float = HUB_TIME

static var DEV_timer_paused: bool = false

static var in_hub: bool = true

func DEV():
	if Input.is_action_just_pressed("dev_pause_timer"):
		DEV_timer_paused = not DEV_timer_paused
	if Input.is_action_just_pressed("dev_goto_hub"):
		goto_room(Room.HUB)
	if Input.is_action_just_pressed("dev_goto_room1"):
		goto_room(Room.ROOM_1)
		
func goto_room(target_room: Room) -> void:
	current_room = target_room
	match target_room:
		Room.HUB:
			time = HUB_TIME
			globals.character.global_position = ROOM_HUB_TELE
			in_hub = true
		Room.ROOM_1:
			time = COMBAT_TIME
			globals.character.global_position = ROOM_1_TELE
			in_hub = false
	anim_player.play("fade_in")	
	globals.character.summon_circle.stop_anim()
	globals.character.camera.tween_parameters.duration = PLAYER_CAMERA_DEFAULT_TWEEN
	ui.particles_off()

func _process(delta: float) -> void:
	DEV()
	
	if DEV_timer_paused == false:
		time -= delta
	if time <= FADE_DURATION:
		anim_player.play("fade_out")
	if time <= PLAYER_SUMMON_DURATION:
		globals.character.summon_circle.start_anim()
	if time <= 3:
		ui.particles_on()
		
	if time <= 0:
		match current_room:
			Room.HUB:
				goto_room(Room.ROOM_1)
			Room.ROOM_1:
				goto_room(Room.HUB)
	calc_earnings()

func calc_earnings() -> int:
	return time * ROOM_MULTI_TEMP
	#print(earnings)
