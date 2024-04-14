extends Node
class_name GameCoordinator

@onready var fill: ColorRect = $CanvasLayer/BlackFill
@onready var anim_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

enum Room {
	HUB,
	ROOM_1,
}

#const ROOM_HUB_TELE := Vector3(0,0,0)
#const ROOM_1_TELE := Vector3(32, 0, 0)

const PLAYER_CAMERA_DEFAULT_TWEEN: float = 0.5
const FADE_DURATION: float = 10.0 / 30.0
const PLAYER_SUMMON_DURATION = 6.0

const HUB_TIME: float = 30.0
const COMBAT_TIME: float = 30.0

static var room_multi: int = 0

static var current_room: Room = Room.HUB
static var current_round: int = 0
static var time: float = HUB_TIME

static var DEV_timer_paused: bool = false

static var in_hub: bool = true

static var room_data: Dictionary = {
	Room.HUB: {
		player_spawn = Vector3(0,0,0)
	},
	Room.ROOM_1: {
		enemy_spawns = []
	},
}


func get_player_spawn_location(room: Room) -> Vector3:
	return room_data[room].player_spawn

func get_enemy_spawns(room: Room) -> Array[Vector3]:
	return room_data[room].enemy_spawns

static func register_spawns(parent: Node, room: Room) -> void:
	for node: Node in parent.get_children():
		if node is Node3D:
			var node3d := node as Node3D
			if node3d.name.begins_with("EnemySpawn"):
				room_data[room].enemy_spawns.append(node3d.global_position)
				continue
			if node3d.name.begins_with("PlayerSpawn"):
				room_data[room].player_spawn = node3d.global_position
				continue

func _ready() -> void:
	print_rich("[b]DEV CONTROLS[/b]\n ~ : Pause/Unpause Timer\n 1 : Goto Hub\n 2 : Goto Room 1\n Tab : Spawn wizard\n M : Spawn enemy\n")

func DEV():
	if Input.is_action_just_pressed("dev_pause_timer"):
		DEV_timer_paused = not DEV_timer_paused
	if Input.is_action_just_pressed("dev_goto_hub"):
		goto_room(Room.HUB)
	if Input.is_action_just_pressed("dev_goto_room1"):
		goto_room(Room.ROOM_1)
	if Input.is_action_just_pressed("dev_spawn_enemy"):
		enemy_manager.spawn_enemy("test", globals.character.global_position)
		
func goto_room(target_room: Room) -> void:
	current_room = target_room
	match target_room:
		Room.HUB:
			time = HUB_TIME
			in_hub = true
			room_multi = 0
		Room.ROOM_1:
			time = COMBAT_TIME
			in_hub = false
			room_multi = 1
	globals.character.global_position = get_player_spawn_location(target_room)
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
	return time * room_multi * current_round
