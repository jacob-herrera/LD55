extends Control
class_name UI

@onready var coins_label: Label = %coins
@onready var mana_bar: ProgressBar = %mana_bar

func _process(_delta: float) -> void:
	coins_label.text = "$" + str(global.coins)
	mana_bar.value = Globals.mana
	mana_bar.max_value = Globals.max_mana
