extends Node
class_name MapChanger

@onready var black: ColorRect = $CanvasLayer/BlackFill
@onready var anim_player : AnimationPlayer = $CanvasLayer/AnimationPlayer

static  var _initalized: bool = false
static var _is_transitioning: bool = false

static var map_path: String
static var is_in_map: bool = false

const MAPS_DIR: String = "res://maps"
static var all_map_names: Array[String] = MapChanger._get_map_names()

const CHARACTER_SCENE: PackedScene = preload("res://scenes/character.tscn")

static func _get_map_path(level_name: String) -> String:
	return "%s/%s.tscn" % [MAPS_DIR, level_name]

static func _get_map_names() -> Array[String]:
	var dir = DirAccess.open(MAPS_DIR)
	var directories: PackedStringArray = dir.get_files()
	var maps: Array[String] = []
	maps.resize(directories.size())
	for i: int in directories.size():
		maps[i] = directories[i].trim_suffix(".tscn")
	return maps

func _ready() -> void:
	set_process(false)
	# If game is started with edited/custom scene.
	var node_name: String = get_tree().current_scene.name
	for map_name: String in all_map_names:
		if node_name == map_name:
			initalize_map()
		
func _process(_delta: float) -> void:
	if not _initalized and get_tree().current_scene != null:
		initalize_map()
			
func initalize_map() -> void:
	var character: Node3D = CHARACTER_SCENE.instantiate()
	is_in_map = true
	get_tree().current_scene.add_child(character)
	set_process(false)
			
func change_map(map_name: String) -> void:
	if map_name.is_empty(): printerr("Empty map_name"); return
	if _is_transitioning: return
	
	is_in_map = false
	map_path = MapChanger._get_map_path(map_name)
	var status: Error = ResourceLoader.load_threaded_request(map_path, "PackedScene", true)

	if status == OK:
		_is_transitioning = true
		anim_player.play("fade_out")
		await anim_player.animation_finished
		get_tree().change_scene_to_file(map_path)
		anim_player.play("fade_in")
		_is_transitioning = false
		set_process(true)
	else:
		printerr("Error changing scene. \n" + error_string(status))
