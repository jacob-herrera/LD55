extends Sprite3D
class_name Healthbar

@onready var subviewport: SubViewport = $SubViewport
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar

@export var enemy_fill: StyleBoxFlat
@export var summon_fill: StyleBoxFlat

func _ready() -> void:
	texture = subviewport.get_texture()

func initalize(max_val: int, col: CollisionShape3D, is_summon: bool) -> void:
	progress_bar.max_value = max_val
	progress_bar.value = max_val
	global_position = Utils.get_top_of_box(col)
	if is_summon:
		progress_bar.add_theme_stylebox_override("fill", summon_fill)
	else:
		progress_bar.add_theme_stylebox_override("fill", enemy_fill)
	
	
func update(val: int) -> void:
	progress_bar.value = val
	#if progress_bar.value <= progress_bar.max_value:
		#progress_bar.theme
