extends Sprite3D
class_name Healthbar

@onready var subviewport: SubViewport = $SubViewport
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar

func _ready() -> void:
	texture = subviewport.get_texture()

func initalize(max_val: int, col: CollisionShape3D) -> void:
	progress_bar.max_value = max_val
	progress_bar.value = max_val
	global_position = Utils.get_top_of_box(col)
	
func update(val: int) -> void:
	progress_bar.value = val
	#if progress_bar.value <= progress_bar.max_value:
		#progress_bar.theme