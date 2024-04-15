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
@onready var preview1: Camera3D = %preview1
@onready var preview2: Camera3D = %preview2
@onready var preview3: Camera3D = %preview3
@onready var swipe: AudioStreamPlayer = $summon_ui/Swipe
@onready var open: AudioStreamPlayer = $summon_ui/Open
@onready var close: AudioStreamPlayer = $summon_ui/Close

@onready var summon_left_arrow: Label = %summon_left_arrow
@onready var summon_right_arrow: Label = %summon_right_arrow

const PREVIEW_OFFSET: Vector3 = Vector3(0, 1, 2)
const OOB: Vector3 = Vector3(0, -100, 0)

var summons: Array[Summon] = []
var selected: int
var selection_max: int

func _process(_delta: float) -> void:
	coins_label.text = "$" + str(Globals.coins)
	earnings.text = "REWARD $" +str(game_coordinator.calc_earnings())
	mana_bar.value = Globals.mana
	mana_bar.max_value = Globals.max_mana
	time.text = str(ceil(GameCoordinator.time))
	fps.text = "FPS:" + str(Engine.get_frames_per_second())
	current_round.text = "ROUND:" + str(GameCoordinator.current_round)
	toggle_earnings()
	
	if Input.is_action_just_pressed("ui_right"):
		selected += 1
		selected = clampi(selected, 0, selection_max)
		play_swipe()
		preview_summons()
	if Input.is_action_just_pressed("ui_left"):
		selected -= 1
		selected = clampi(selected, 0, selection_max)
		play_swipe()
		preview_summons()
	if Globals.is_in_summon_ui and Input.is_action_just_pressed("primary_action"):
		summon_selected()
		
func summon_selected() -> void:
	if summons.is_empty():
		return
	if Globals.mana >= 10:
		Globals.mana -= 10
		globals.character.drop_current_carry()
		exit_summon_ui()
		var selected_summon: Summon = summons[selected]
		if is_instance_valid(selected_summon):
			globals.character.carrying = selected_summon
			game_coordinator.anim_player.play("fade_in")
			globals.mana -= 10
	else:
		# TODO NOT ENOUGH MANA SOUND
		pass
		
func enter_summon_ui() -> void:
	Controls.lock_movement = true
	Globals.is_in_summon_ui = true
	
	summon_ui.visible = true

	summons.clear()
	for node: Node in get_tree().get_nodes_in_group(Summon.GROUP):
		if not node is Summon: printerr("wtf"); continue
		var summon := node as Summon
		summons.append(summon)
	selection_max = summons.size() - 1
	open.play()
	
	preview_summons()
	
		
func preview_summons() -> void:
	var selected_summon: Summon = null
	var previous_summon: Summon = null
	var next_summon: Summon = null
	
	if selected - 1 >= 0:
		previous_summon = summons[selected - 1]
	if selected + 1 < summons.size():
		next_summon = summons[selected + 1]
	if not summons.is_empty():
		selected_summon = summons[selected]
		
	if is_instance_valid(previous_summon):
		preview1.global_position = previous_summon.get_center() + PREVIEW_OFFSET
		summon_left_arrow.visible = true
	else:
		preview1.global_position = OOB
		summon_left_arrow.visible = false
		
	if is_instance_valid(selected_summon):
		preview2.position = selected_summon.get_center() + PREVIEW_OFFSET
	else:
		preview2.global_position = OOB
		
	if is_instance_valid(next_summon):
		preview3.position = next_summon.get_center() + PREVIEW_OFFSET
		summon_right_arrow.visible = true
	else:
		preview3.global_position = OOB
		summon_right_arrow.visible = false
	
func exit_summon_ui() -> void:
	Globals.is_in_summon_ui = false
	Controls.lock_movement = false
	summon_ui.visible = false
	if is_instance_valid(globals.character.carrying):
		close.play()

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
		
func play_swipe() -> void:
	if summon_ui.visible:
		swipe.play()
