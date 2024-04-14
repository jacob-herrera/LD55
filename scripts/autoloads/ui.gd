extends Control
class_name UI

@onready var coins_label: Label = %coins
@onready var mana_bar: ProgressBar = %mana_bar
@onready var time: Label = %timer
@onready var fps: Label = $FPS
@onready var shop: Node = $shop_ui
@onready var freeze: Node = $shop_ui/freeze
@onready var frozen: Node = $shop_ui/frozen
@onready var purchase: Node = $shop_ui/purchase
@onready var purchased: Node = $shop_ui/purchased
@onready var screeen_particles: CPUParticles2D = $screen_particles

func _process(_delta: float) -> void:
	coins_label.text = "$" + str(Globals.coins)
	mana_bar.value = Globals.mana
	mana_bar.max_value = Globals.max_mana
	time.text = str(ceil(GameCoordinator.time))
	fps.text = "FPS:" + str(Engine.get_frames_per_second())

func particles_on() -> void:
	screeen_particles.emitting = true
	screeen_particles.visible = true
	
func particles_off() -> void:
	screeen_particles.restart()
	screeen_particles.emitting = false
	#screeen_particles.visible = false
