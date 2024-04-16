extends Node
@export var cameras: Array[PhantomCamera3D]

@onready var area: Area3D = $Area3D

@onready var purchase_SFX: AudioStreamPlayer = $PurchaseSound
@onready var swipe_SFX: AudioStreamPlayer = $ShopSwipeSound
@onready var enter_SFX: AudioStreamPlayer = $EnterExitShopSound
@onready var freeze_SFX: AudioStreamPlayer = $FreezeSound
@onready var steam_SFX: AudioStreamPlayer = $SteamSound
@onready var dice_SFX: AudioStreamPlayer = $DiceRollSound

var current_item = 0
var in_shop = false
var debounce: bool = false

@export var freeze_bodies: Array[StaticBody3D]
#@export var freeze_meshes: MeshIns

const POOL_SIZE: int = 10
const POOL : Array[Dictionary] = [
	## ROUND 0
	{
		Summon.Type.WIZARD: 0,
		Summon.Type.SNOWMAN: 1,
		Summon.Type.ARCHER: 16,
		Summon.Type.BARD: 1,
		Summon.Type.SHIELD: 5,
		Summon.Type.RABBIT: 1
	},
	## ROUND 1
	{
		Summon.Type.WIZARD: 0,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 5,
		Summon.Type.BARD: 1,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 1
	},
	## ROUND 2
	{
		Summon.Type.WIZARD: 0,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 5,
		Summon.Type.BARD: 2,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 2
	},
	## ROUND 3
	{
		Summon.Type.WIZARD: 0,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 5,
		Summon.Type.BARD: 2,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 2
	},
	## ROUND 4
	{
		Summon.Type.WIZARD: 0,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 5,
		Summon.Type.BARD: 2,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 2
	},
	## ROUND 5
	{
		Summon.Type.WIZARD: 0,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 3,
		Summon.Type.BARD: 2,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 2
	},
	## ROUND 6
	{
		Summon.Type.WIZARD: 0,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 3,
		Summon.Type.BARD: 2,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 2
	},
	## ROUND 7
	{
		Summon.Type.WIZARD: 2,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 2,
		Summon.Type.BARD: 2,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 2
	},
	## ROUND 8
	{
		Summon.Type.WIZARD: 2,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 2,
		Summon.Type.BARD: 2,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 2
	},
	## ROUND 9
	{
		Summon.Type.WIZARD: 5,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 0,
		Summon.Type.BARD: 2,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 2
	},
	## ROUND 10
	{
		Summon.Type.WIZARD: 5,
		Summon.Type.SNOWMAN: 5,
		Summon.Type.ARCHER: 0,
		Summon.Type.BARD: 2,
		Summon.Type.SHIELD: 2,
		Summon.Type.RABBIT: 2
	},
]

var pedestal_locaction: Array[Vector3] = [
	Vector3(-4.5, 0.5, -5.5),
	Vector3(-3, 0.5, -5.5),
	Vector3(-1.5, 0.5, -5.5),
	Vector3(0, 0.5, -5.5),
]

var rng = RandomNumberGenerator.new()
const REROLL_INDEX: int = 4
const REROLL_COST: int = 10
#var preview_nodes: Array[Node3D] = []
const N_SLOTS: int = 4
var slots: Array[Dictionary] = []

var freeze_invisible: Array[Vector3]
var freeze_visible: Array[Vector3]
@export var freeze_meshes: Array[MeshInstance3D]

func visible_freeze(i: int, vis: bool) -> void:
	if vis:
		freeze_bodies[i].global_position = freeze_visible[i]
		freeze_meshes[i].visible = true
	else:
		freeze_bodies[i].global_position = freeze_invisible[i]
		freeze_meshes[i].visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	ui.freeze_button.pressed.connect(_freeze_button_pressed)
	ui.purchase_button.pressed.connect(_purchase_button_pressed)
	game_coordinator.goto_hub.connect(reroll)
	
	for body: StaticBody3D in freeze_bodies:
		freeze_visible.append(body.global_position)
		freeze_invisible.append(body.global_position-Vector3(0,2,0))
	
	visible_freeze(0, false)
	visible_freeze(1, false)
	visible_freeze(2, false)
	visible_freeze(3, false)
	
	for index: int in range(5):
		var display_data = {}
		display_data.is_frozen = false
		display_data.is_purchased = false
		display_data.is_reroll = false
		display_data.dps = -1
		display_data.cost = -1
		display_data.health = -1
		display_data.desc = "ERROR"
		display_data.name = "ERROR"
		display_data.type = Summon.Type.WIZARD
		display_data.preview = null
		slots.append(display_data)
		
	slots[4].is_reroll = true
	
	reroll()
	
	
	#for i in range(cameras.size() - 1):
		#var random_weight = rng.randi_range(1, total_weight)
		#var curRange = 0
		#for key in pool[1].keys():
			#curRange += pool[1][key][0]
			#if idx <= curRange:
				#slots.append([Summon.TYPE_TO_STRING[key], pool[1][key][1], false, "lorem ipsum", 1, 1])

				#preview_arr.append(preview)
				#break
				
				
	#print(slots)



func _process(_delta: float):
	if in_shop == true:
		var is_selecting_reroll: bool = current_item == cameras.size() - 1
		var is_slot_empty: bool = false
				
		ui.purchase_button.modulate = Color.WHITE
		if is_selecting_reroll:
			ui.shop_name.text = "reroll shop"
			ui.shop_desc.text = "REROLL UNFROZEN SUMMONS FOR SALE"
			ui.dps.text = ""
			ui.health.text = ""
			ui.cost.text = ""
			ui.reroll_cost.text = "$" + str(REROLL_COST)
			ui.purchase_button.visible = true
			ui.freeze_button.visible = false
			ui.middle_selection.visible = not ui.shop_selecting_buttons
			if REROLL_COST > Globals.coins:
				ui.purchase_button.modulate = Color.DIM_GRAY
		else:
			ui.freeze_button.visible = true
			is_slot_empty = slots[current_item].is_purchased
			
			if is_slot_empty:
				ui.shop_desc.text = ""
				ui.shop_name.text = ""
				ui.dps.text = ""
				ui.health.text = ""
				ui.cost.text = ""
				ui.reroll_cost.text = ""
				ui.freeze_button.visible = false
				ui.purchase_button.visible = false
				ui.middle_selection.visible = false
			else:
				ui.shop_name.text = slots[current_item].name
				ui.shop_desc.text = slots[current_item].desc
				ui.dps.text = "DPS:" + str(slots[current_item].dps)
				ui.health.text = "HP:" + str(slots[current_item].health)
				ui.cost.text = "$" + str(slots[current_item].cost)
				ui.reroll_cost.text = ""
				ui.freeze_button.visible = true
				ui.purchase_button.visible = true
				ui.middle_selection.visible = not ui.shop_selecting_buttons
				if slots[current_item].is_frozen:
					ui.freeze_button.text = "UNFREEZE"
				else:
					ui.freeze_button.text = "FREEZE"
				
				var price: int = slots[current_item].cost
				if price > Globals.coins:
					ui.purchase_button.modulate = Color.DIM_GRAY
				
				
		if (Input.is_action_just_pressed("ui_up") or \
			Input.is_action_just_pressed("ui_accept")) \
			and UI.shop_selecting_buttons == false:
			if not is_slot_empty:
				ui.focus_buttons()
				ui.open.play()
				#ui.purchase.visible = true;
				#ui.purchased.visible = false;
		
		if Input.is_action_just_pressed("ui_right") \
		and UI.shop_selecting_buttons == false:
			cameras[current_item].set_priority(0)
			swipe_SFX.play()
			current_item += 1
			current_item = current_item % cameras.size()
			cameras[current_item].set_priority(20)
			
		if Input.is_action_just_pressed("ui_left") \
		and UI.shop_selecting_buttons == false:
			cameras[current_item].set_priority(0)
			swipe_SFX.play()
			current_item -= 1
			if(current_item < 0):
				current_item += cameras.size()
			cameras[current_item].set_priority(20)
			


				
		if Input.is_action_just_pressed("ui_down"):
			if UI.shop_selecting_buttons == true:
				ui.unfocus_button()
				ui.close.play()
			else:
				exit_shop()
			#

					
		if Input.is_action_just_pressed("ui_cancel"):
			if UI.shop_selecting_buttons == true:
				ui.unfocus_button()
			else:
				exit_shop()
			

func _purchase_button_pressed() -> void:
	if current_item != REROLL_INDEX:
		var price: int = slots[current_item].cost
		if not slots[current_item].is_purchased and Globals.coins >= price:
			Globals.coins -= price
			globals.character.drop_current_carry()
			var summon: Summon = summon_manager.spawn_summon(slots[current_item].type)
			get_tree().current_scene.add_child(summon)
			summon.global_position = Vector3(randf(), 0.0, randf()) + Vector3(0,0,-3)
			purchase_SFX.play()
			slots[current_item].is_purchased = true
			visible_freeze(current_item, false)
			slots[current_item].is_frozen = false
			if is_instance_valid(slots[current_item].preview):
				slots[current_item].preview.queue_free()
			ui.unfocus_button()
	else:
		if Globals.coins - REROLL_COST >= 0:
			Globals.coins -= REROLL_COST
			dice_SFX.play()
			current_item = 0
			cameras[0].set_priority(20)
			ui.unfocus_button()
			reroll()
			
func _freeze_button_pressed() -> void:
	if current_item != REROLL_INDEX and slots[current_item].is_purchased == false:
		if slots[current_item].is_frozen:
			steam_SFX.play()
			freeze_SFX.stop()
			visible_freeze(current_item, false)
		else:
			ui.unfocus_button()
			freeze_SFX.play()
			steam_SFX.stop()
			visible_freeze(current_item, true)
			
		slots[current_item].is_frozen = not slots[current_item].is_frozen
	
var char_was_in_area_last_frame: bool = false

func _physics_process(_delta: float) -> void:
	var overlap: Array[Node3D] = area.get_overlapping_bodies()
	var char_is_in_area_this_frame: bool = false
	
	for node: Node3D in overlap:
		if node is Character:
			var character := node as Character
			char_is_in_area_this_frame = true
			if character.is_on_floor() and character.position.y < 0.3:
				enter_shop()
				
	#if char_is_in_area_this_frame and not char_was_in_area_last_frame:
		#print("entered")
	
	if not char_is_in_area_this_frame and char_was_in_area_last_frame:
		if GameCoordinator.current_room != GameCoordinator.Room.HUB:
			globals.character.camera.tween_parameters.duration = 0
		exit_shop()
		debounce = false
				
	char_was_in_area_last_frame = char_is_in_area_this_frame
	
func enter_shop():
	if not in_shop and not debounce:
		debounce = true
		in_shop = true
		enter_SFX.play()
		if Globals.is_in_summon_ui:
			ui.exit_summon_ui()
		Controls.lock_movement = true
		globals.character.velocity = Vector3.ZERO
		Globals.is_in_shop = true
		cameras[0].set_priority(20)
		current_item = 0
		ui.shop.visible = true
		ui.unfocus_button()
			
func exit_shop() -> void:
	if in_shop:
		for cam: PhantomCamera3D in cameras:
			cam.set_priority(0)
		enter_SFX.play()
		Controls.lock_movement = false
		Globals.is_in_shop = false
		in_shop = false
		ui.shop.visible = false
		ui.unfocus_button()
	
func reroll() -> void:
	var current_round: int = min(POOL_SIZE, GameCoordinator.current_round)
	
	var distribution: Array[Summon.Type] = []
	var total_weight: int = 0;
	
	for summon_type: Summon.Type in POOL[current_round]:
		var weight: int = POOL[current_round][summon_type]
		for i in range(weight):
			distribution.append(summon_type)
		total_weight += weight
		
	
	for index: int in range(N_SLOTS):
		if slots[index].is_frozen:
			continue
		if is_instance_valid(slots[index].preview):
			slots[index].preview.queue_free()
			
		var random_weight: int = rng.randi_range(0, total_weight-1)
		var summon_type: Summon.Type = distribution[random_weight]
		var shop_data: Dictionary = summon_manager.get_shop_data(summon_type)
		slots[index].is_frozen = false
		slots[index].is_purchased = false
		slots[index].is_reroll = false
		slots[index].dps = shop_data.dps
		slots[index].cost = shop_data.cost
		slots[index].health = shop_data.health
		slots[index].name = shop_data.name + " SUMMON"
		slots[index].desc = shop_data.desc
		slots[index].type = summon_type
		var preview: Node3D = summon_manager.get_preview_of_summon(summon_type)
		add_child(preview)
		preview.global_position = pedestal_locaction[index]
		slots[index].preview = preview

