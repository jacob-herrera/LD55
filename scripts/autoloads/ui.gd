extends Control
class_name UI

@onready var coins_label: Label = %coins
@onready var mana_bar: ProgressBar = %mana_bar
@onready var time: Label = %timer
@onready var fps: Label = $FPS
@onready var wave_outcome: Label = $outcome
@onready var wave_player: AnimationPlayer = $outcome/AnimationPlayer
@onready var earnings: Label = %earnings
@onready var shop: Node = $shop_ui
@onready var space: Label = %space
@onready var shop_desc: Label = %shop_desc
@onready var shop_name: Label = %shop_name

@onready var dps: Node = %DPS
@onready var health: Node = %health
@onready var cost: Node = %cost
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
@onready var murp: AudioStreamPlayer = $"summon_ui/Not Enough Mana"
@onready var life_1: Sprite2D = $Lives/Life_1
@onready var life_2: Sprite2D = $Lives/Life_2
@onready var life_3: Sprite2D = $Lives/Life_3
@onready var remaining: Label = %remaining
@onready var middle_container: SubViewportContainer = %middle_container
@onready var summon_left_arrow: Label = %summon_left_arrow
@onready var summon_right_arrow: Label = %summon_right_arrow
@onready var shop_left: Label = $shop_ui/shop_left
@onready var shop_right: Label = $shop_ui/shop_right
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound

@onready var purchase_button: Button = %purchase_button
@onready var freeze_button: Button = %freeze_button
@onready var buttons_container: HBoxContainer = %buttons_container
@onready var middle_selection: Panel = %middle_selection_box

static var shop_selecting_buttons: bool = false

const PREVIEW_OFFSET: Vector3 = Vector3(0, 1, 2)
const OOB: Vector3 = Vector3(0, -100, 0)

var summons: Array[Summon] = []
var selected: int
var selection_max: int
var first_gameover_play = true

func _ready() -> void:
	shop.visible = false
	
func _process(_delta: float) -> void:
	coins_label.text = "$" + str(Globals.coins)
	earnings.text = "REWARD $" +str(game_coordinator.calc_earnings())
	mana_bar.value = Globals.mana
	mana_bar.max_value = Globals.max_mana
	time.text = str(ceil(GameCoordinator.time))
	fps.text = "FPS:" + str(Engine.get_frames_per_second())
	current_round.text = "ROUND:" + str(GameCoordinator.current_round)
	remaining.text = str(EnemyManager.current_room_remaining_enemies) \
	+ "/" + str(EnemyManager.current_room_max_enemies)
	check_lives()	
	
	if GameCoordinator.current_room == GameCoordinator.Room.HUB:
		earnings.visible = false
		#wave_outcome.visible = true
		remaining.visible = false
	else:
		earnings.visible = true
		#wave_outcome.visible = false
		remaining.visible = true
	
	if Input.is_action_just_pressed("ui_right"):
		selected += 1
		if selected > selection_max:
			selected = clampi(selected, 0, selection_max)
		else:
			play_swipe()
			preview_summons()
	if Input.is_action_just_pressed("ui_left"):
		selected -= 1
		if selected < 0:
			selected = clampi(selected, 0, selection_max)
		else:
			play_swipe()
			preview_summons()
			
	if Globals.is_in_summon_ui and Input.is_action_just_pressed("primary_action"):
		summon_selected()
		
func summon_selected() -> void:
	if summons.is_empty():
		return
	var selected_summon: Summon = summons[selected]
	if Globals.mana >= Globals.SUMMON_MANA_COST and is_instance_valid(selected_summon):
		Globals.mana -= Globals.SUMMON_MANA_COST
		globals.character.drop_current_carry()
		globals.character.carrying = selected_summon
		game_coordinator.anim_player.play("fade_in")
		exit_summon_ui()
	else:
		murp.play()
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
	
	selected = 0
	preview_summons()
	
func focus_buttons() -> void:
	shop_selecting_buttons = true
	purchase_button.grab_focus()
	shop_left.visible = false
	shop_right.visible = false
	space.visible = true
	buttons_container.modulate = Color.WHITE
	middle_selection.visible = false
		
func unfocus_button() -> void:
	shop_selecting_buttons = false
	purchase_button.release_focus()
	freeze_button.release_focus()
	shop_left.visible = true
	shop_right.visible = true
	space.visible = false
	#middle_selection.visible = true
	buttons_container.modulate = Color(0.9,0.9,0.9)
		
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

func check_lives() -> void:
	if GameCoordinator.wave_cleared == true:
		wave_outcome.add_theme_color_override("font_color", Color(0,255,0))
		wave_outcome.text = "Wave Cleared!"
	else:
		wave_outcome.add_theme_color_override("font_color", Color(255,0,0))
		wave_outcome.text = "Wave Failed!"
	
	if globals.lives == 2:		
		life_3.hide()
	if globals.lives == 1:
		life_2.hide()
	if globals.lives == 0:
		if first_gameover_play:
			game_over_sound.play()
			first_gameover_play = false
		life_1.hide()
		ui.visible = false
		print("TODO GAMEOVER")
		get_tree().change_scene_to_file("res://scenes/gameover.tscn")
	
func exit_summon_ui() -> void:
	Globals.is_in_summon_ui = false
	Controls.lock_movement = false
	summon_ui.visible = false
	if not is_instance_valid(globals.character.carrying):
		close.play()

func particles_on() -> void:
	screeen_particles.emitting = true
	screeen_particles.visible = true
	
func particles_off() -> void:
	screeen_particles.restart()
	screeen_particles.emitting = false
	

func play_swipe() -> void:
	if summon_ui.visible:
		swipe.play()
		
func clear() -> void:
	queue_free()
