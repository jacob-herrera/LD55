extends Node
class_name GameCoordinator

enum GameState {
	HUB,
	COMBAT
}

const HUB_TELE := Vector3(0,0,0)
const LEVEL_1_TELE := Vector3(32, 0, 0)


const HUB_TIME: float = 15.0
const COMBAT_TIME: float = 15.0

static var state: GameState = GameState.HUB

static var time: float = HUB_TIME

func _process(delta: float) -> void:
	time -= delta
	if time <= 0:
		match state:
			GameState.HUB:
				state = GameState.COMBAT
				globals.character.global_position = LEVEL_1_TELE
				time = COMBAT_TIME
			GameState.COMBAT:
				state = GameState.HUB
				globals.character.global_position = HUB_TELE
				time = HUB_TIME
				

