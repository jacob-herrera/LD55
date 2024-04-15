extends Node
class_name GameCoordinator

@onready var fill: ColorRect = $CanvasLayer/BlackFill
@onready var anim_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

enum Room {
	HUB,
	ROOM_1,
	ROOM_2,
	ROOM_3
}

const ROOM_HUB_TELE := Vector3(0,0,0)
const ROOM_1_TELE := Vector3(32, 0, 0)

const PLAYER_CAMERA_DEFAULT_TWEEN: float = 0.5
const FADE_DURATION: float = 10.0 / 30.0
const PLAYER_SUMMON_DURATION = 6.0

const HUB_TIME: float = 30.0
const COMBAT_TIME: float = 30.0

static var room_multiplier: float = 0

static var current_room: Room = Room.HUB
static var current_round: int = 0
static var time: float = HUB_TIME

static var DEV_timer_paused: bool = false

static var room_data: Dictionary = {
	Room.HUB: {
		player_spawn = Vector3(0, 0, 0)
	},
	Room.ROOM_1: {
		enemy_spawns = []
	},
	Room.ROOM_2: {
		enemy_spawns = []
	},
	Room.ROOM_3: {
		enemy_spawns = []
	},
} 

func _ready() -> void:
	print_rich("[b]DEV CONTROLS[/b]\n ~ : Pause/Unpause Timer\n 1 : Goto Hub\n 2 : Goto Room 1\n Tab : Spawn wizard\n M : Spawn enemy\n")

func DEV():
	if Input.is_action_just_pressed("dev_pause_timer"):
		DEV_timer_paused = not DEV_timer_paused
	if Input.is_action_just_pressed("dev_goto_hub"):
		goto_room(Room.HUB)
	if Input.is_action_just_pressed("dev_goto_room1"):
		goto_room(Room.ROOM_1)
	if Input.is_action_just_pressed("dev_goto_room2"):
		goto_room(Room.ROOM_2)
	if Input.is_action_just_pressed("dev_goto_room3"):
		goto_room(Room.ROOM_3)
	if Input.is_action_just_pressed("dev_spawn_enemy"):
		if current_room != Room.HUB:
			spawn_enemy_in_current_room()
		else:
			enemy_manager.spawn_enemy("test", globals.character.global_position)
	if Input.is_action_just_pressed("dev_spawn_summon"):
		summon_manager.give_player_summon("wizard")
		
static func register_room(node: Node3D, room: Room) -> void:
	for p: Node in node.get_children():	
		if not (p is Marker3D): continue
		var marker: Marker3D = p as Marker3D
		if marker.name.begins_with("PlayerSpawn"):
			room_data[room].player_spawn = marker.global_position
		elif marker.name.begins_with("EnemySpawn"):
			room_data[room].enemy_spawns.append(marker.global_position)

func spawn_enemy_in_current_room() -> void:
	var rand_pos: Vector3 = room_data[current_room].enemy_spawns.pick_random()
	enemy_manager.spawn_enemy("test", rand_pos)
	
func goto_room(target_room: Room) -> void:
	current_room = target_room
	match target_room:
		Room.HUB:
			time = HUB_TIME
		_:
			time = COMBAT_TIME
			current_round += 1
			
	globals.character.global_position = room_data[target_room].player_spawn
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
				var room: Room = randi_range(1,3) as Room
				print(room)
				goto_room(room)
			_:
				goto_room(Room.HUB)
	calc_earnings()

func calc_earnings() -> int:
	# multiply by round? wtf that will scale too fast
	#return round(time * room_multiplier * float(current_round)) as int
	return round(time * 100)
