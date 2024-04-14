extends Control
class_name UI

@onready var coins_label: Label = %coins
@onready var mana_bar: ProgressBar = %mana_bar
@onready var time: Label = %timer
@onready var fps: Label = $FPS


func _process(_delta: float) -> void:
	coins_label.text = "$" + str(Globals.coins)
	mana_bar.value = Globals.mana
	mana_bar.max_value = Globals.max_mana
	time.text = str(ceil(GameCoordinator.time))
	fps.text = "FPS:" + str(Engine.get_frames_per_second())
