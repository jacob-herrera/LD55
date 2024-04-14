extends Node3D
class_name SummonCircle

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	stop_anim()

func start_anim() -> void:
	sprite.visible = true
	anim_player.play("summon_spin")

func stop_anim() -> void:
	anim_player.play("RESET")
	sprite.visible = false
