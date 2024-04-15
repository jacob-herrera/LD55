extends Control
class_name UI

@onready var coins_label: Label = %coins
@onready var mana_bar: ProgressBar = %mana_bar
@onready var time: Label = %timer
@onready var fps: Label = $FPS
@onready var earnings: Label = %earnings
@onready var shop: Node = $shop_ui
@onready var freeze: Node = $shop_ui/freeze
@onready var frozen: Node = $shop_ui/frozen
@onready var purchase: Node = $shop_ui/purchase
@onready var purchased: Node = $shop_ui/purchased
@onready var description: Node = $shop_ui/description
@onready var dps: Node = $shop_ui/DPS
@onready var health: Node = $shop_ui/health
@onready var cost: Node = $shop_ui/cost
@onready var reroll_cost: Node = $shop_ui/rerollCost
@onready var screeen_particles: CPUParticles2D = $screen_particles
@onready var current_round: Label = %round
@onready var summon_ui: Panel = $summon_ui 

func _process(_delta: float) -> void:
	coins_label.text = "$" + str(Globals.coins)
	earnings.text = "REWARD $" +str(game_coordinator.calc_earnings())
	mana_bar.value = Globals.mana
	mana_bar.max_value = Globals.max_mana
	time.text = str(ceil(GameCoordinator.time))
	fps.text = "FPS:" + str(Engine.get_frames_per_second())
	current_round.text = "ROUND:" + str(GameCoordinator.current_round)
	toggle_earnings()
	
func enter_summon_ui() -> void:
	summon_ui.visible = true
	
func exit_summon_ui() -> void:
	summon_ui.visible = false

func particles_on() -> void:
	screeen_particles.emitting = true
	screeen_particles.visible = true
	
func particles_off() -> void:
	screeen_particles.restart()
	screeen_particles.emitting = false
	#screeen_particles.visible = false
	
func toggle_earnings() -> void:
	if GameCoordinator.current_room == GameCoordinator.Room.HUB:
		earnings.visible = false
	else:
		earnings.visible = true
