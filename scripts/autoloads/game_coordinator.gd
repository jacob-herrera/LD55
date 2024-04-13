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

const HUB_TIME: float = 15.0
const COMBAT_TIME: float = 30.0

static var state: GameState = GameState.HUB
static var round: int = 0
static var time: float = HUB_TIME

func _process(delta: float) -> void:
	time -= delta
	if time <= FADE_DURATION:
		anim_player.play("fade_out")
	
	if time <= 0:
		# Reset tween
		globals.character.camera.tween_parameters.duration = PLAYER_CAMERA_DEFAULT_TWEEN
		match state:
			GameState.HUB:
				state = GameState.COMBAT
				globals.character.global_position = LEVEL_1_TELE
				time = COMBAT_TIME
			GameState.COMBAT:
				state = GameState.HUB
				globals.character.global_position = HUB_TELE
				time = HUB_TIME
				round += 1
		anim_player.play("fade_in")	

