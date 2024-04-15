extends Sprite3D
class_name Healthbar

@export var enemy_texture: CompressedTexture2D
@export var summon_texture: CompressedTexture2D

var max_value: int

func initalize(max_hp: int, pos: Vector3, is_summon: bool) -> void:
	max_value = max_hp
	frame = 0
	global_position = pos
	
	if is_summon:
		texture = summon_texture
	else:
		texture = enemy_texture
	
func update(value: int) -> void:
	var percent: float = 1.0 - (float(value) / float(max_value))
	var float_frame: float = percent * vframes
	frame = clampi(ceil(float_frame), 0, vframes - 1)
