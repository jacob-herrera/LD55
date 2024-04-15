extends Node3D
class_name SummonCircle

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite3D = $Sprite3D
@onready var teleport: AudioStreamPlayer3D = $Teleport

func _ready() -> void:
	stop_anim()

func start_anim() -> void:
	sprite.visible = true
	anim_player.play("summon_spin")
	play_teleport()

func stop_anim() -> void:
	anim_player.play("RESET")
	sprite.visible = false

func play_teleport() -> void:
	await get_tree().create_timer(0.01).timeout
	if !teleport.playing && sprite.visible:
		teleport.play()
	
