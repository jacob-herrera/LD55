extends Control

@onready var coins_label: Label = %coins

func _process(_delta: float) -> void:
	coins_label.text = "$" + str(global.coins)
