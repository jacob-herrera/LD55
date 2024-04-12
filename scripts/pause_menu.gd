extends Control
class_name PauseMenu

@onready var resume_button: Button = %Resume
@onready var settings_button: Button = %Settings
#@onready var quit_button: Button = %Quit

func _ready() -> void:
	resume_button.pressed.connect(_resume_pressed)
	settings_button.pressed.connect(_settings_pressed)
#	quit_button.pressed.connect(_quit_pressed)
	resume_button.grab_focus()
	
func _resume_pressed() -> void:
	pauser.unpause()

func _settings_pressed() -> void:
	pass

#func _quit_pressed() -> void:
	#get_tree().quit()
