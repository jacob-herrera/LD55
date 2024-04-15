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

static var wave_cleared: bool = false
static var _played_wave_clear_animation: bool = false
static var _has_started_summon_circle: bool = false
static var room_multiplier: float = 0

signal goto_hub

static var current_room: Room = Room.HUB
static var num_enemies: int = 1
static var current_round: int = 0
static var time: float = HUB_TIME
static var enemy_order: Array = ["basic", "basic", "basic", "strong"]

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
	print_rich(
		"""
			[b]DEV CONTROLS[/b]
			~ : Pause/Unpause Timer
			
			1 : Goto Hub
			2-4 : Goto Room X
			
			I : Spawn wizard
			O : Spawn snowman
			
			M : Spawn enemy
		"""
	)

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
	if Input.is_action_just_pressed("dev_spawn_wizard"):
		summon_manager.give_player_summon(Summon.Type.WIZARD)
	if Input.is_action_just_pressed("dev_spawn_snowman"):
		summon_manager.give_player_summon(Summon.Type.SNOWMAN)
		
		
static func register_room(node: Node3D, room: Room) -> void:
	for p: Node in node.get_children():	
		if not (p is Marker3D): continue
		var marker: Marker3D = p as Marker3D
		if marker.name.begins_with("PlayerSpawn"):
			room_data[room].player_spawn = marker.global_position
		elif marker.name.begins_with("EnemySpawn"):
			room_data[room].enemy_spawns.append(marker.global_position)

func spawn_enemy_in_current_room() -> void:
	for i in range(num_enemies):
		var rand_pos: Vector3 = room_data[current_room].enemy_spawns.pick_random()
		enemy_manager.spawn_enemy(enemy_order[i % enemy_order.size()], rand_pos)	
	
func goto_room(target_room: Room) -> void:
	# extra call to remove and check enemis for dev teleporting
	current_room = target_room
	match target_room:
		Room.HUB:
			time = HUB_TIME
			enemy_manager.check_enemies()
			enemy_manager.remove_enemies()
			
			emit_signal("goto_hub")
		_:			
			time = COMBAT_TIME
			current_round += 1
			# extra call to increment num_enemies for dev teleporting
			num_enemies += 1
			EnemyManager.current_room_max_enemies = num_enemies
			EnemyManager.current_room_remaining_enemies = num_enemies
			enemy_manager.remove_enemies()
			spawn_enemy_in_current_room()
			_played_wave_clear_animation = false
			
	_has_started_summon_circle = false
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
	if time <= PLAYER_SUMMON_DURATION and not _has_started_summon_circle:
		_has_started_summon_circle = true
		globals.character.summon_circle.start_anim()
		ui.particles_on()
	#if time <= PLAYER_SUMMON_DURATION:
		
	
	enemy_manager.recalc_remaining_enemies()
	if current_room != Room.HUB:
		wave_cleared = enemy_manager.current_room_remaining_enemies == 0
	calc_earnings()
	if current_room != Room.HUB and wave_cleared:
		if time > PLAYER_SUMMON_DURATION:
			Globals.coins += calc_earnings()
			time = PLAYER_SUMMON_DURATION
			
		if not _played_wave_clear_animation:
			_played_wave_clear_animation = true
			ui.wave_player.play("fade_away")
	
	if time <= 0:
		match current_room:
			Room.HUB:
				var random_room: Room = randi_range(1,3) as Room
				goto_room(random_room)
			_:
				enemy_manager.remove_enemies()
				goto_room(Room.HUB)
				print("here", wave_cleared)
				if wave_cleared == false:
					ui.wave_player.play("fade_away")
				
	
	
	

func calc_earnings() -> int:
	# multiply by round? wtf that will scale too fast
	#return round(time * room_multiplier * float(current_round)) as int
	return round(time)
