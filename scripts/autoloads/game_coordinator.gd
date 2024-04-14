extends Node
class_name GameCoordinator

@onready var fill: ColorRect = $CanvasLayer/BlackFill
@onready var anim_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

enum GameState {
	HUB,
	COMBAT
}

const HUB_TELE := Vector3(0,0,0)
const LEVEL_1_TELE := Vector3(32, 0, 0)

const PLAYER_CAMERA_DEFAULT_TWEEN: float = 0.5
const FADE_DURATION: float = 10.0 / 30.0
const PLAYER_SUMMON_DURATION = 6.0
const HUB_TIME: float = 10.0
const COMBAT_TIME: float = 10.0

static var state: GameState = GameState.HUB
static var current_round: int = 0
static var time: float = HUB_TIME

static var DEV_timer_paused: bool = false

func _process(delta: float) -> void:
	if DEV_timer_paused == false:
		time -= delta
	if time <= FADE_DURATION:
		anim_player.play("fade_out")
	if time <= PLAYER_SUMMON_DURATION:
		globals.character.summon_circle.start_anim()
	if time <= 3:
		ui.particles_on()
	if time <= 0:
		# Reset tween
		match state:
			GameState.HUB:
				state = GameState.COMBAT
				globals.character.global_position = LEVEL_1_TELE
				time = COMBAT_TIME
			GameState.COMBAT:
				state = GameState.HUB
				globals.character.global_position = HUB_TELE
				time = HUB_TIME
				current_round += 1
		anim_player.play("fade_in")	
		globals.character.summon_circle.stop_anim()
		globals.character.camera.tween_parameters.duration = PLAYER_CAMERA_DEFAULT_TWEEN
		ui.particles_off()

