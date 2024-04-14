extends Node
@export var cameras: Array[PhantomCamera3D]
@export var ShopSounds: Array[AudioStreamPlayer]

@onready var purchase_SFX: AudioStreamPlayer = $PurchaseSound
@onready var swipe_SFX: AudioStreamPlayer = $ShopSwipeSound
@onready var enter_SFX: AudioStreamPlayer = $EnterExitShopSound
@onready var freeze_SFX: AudioStreamPlayer = $FreezeSound
@onready var steam_SFX: AudioStreamPlayer = $SteamSound
@onready var dice_SFX: AudioStreamPlayer = $DiceRollSound

var current_item = 0
var in_shop = false
var in_area: bool = false
var pool = {
 1: {archer = [3, 5], knight = [3, 5], farmer = [1, 10]},
 2: {archer = [3, 5], knight = [3, 5], farmer = [3, 10]},
 3: {archer = [1, 5], knight = [1, 5], farmer = [2, 10], wizard = [2, 15]}
}
var current_display = []
var rng = RandomNumberGenerator.new()
var rerollPrice = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	var total = 0;
	for val in pool[1].values():
		total += val[0]
	for i in range(cameras.size() - 1):
		var idx = rng.randi_range(1, total)
		var curRange = 0
		for key in pool[1].keys():
			curRange += pool[1][key][0]
			if idx <= curRange:
				current_display.append([key, pool[1][key][1], false, "lorem ipsum", 1, 1])
				break
	print(current_display)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if in_shop == true:
		
		if(current_item == cameras.size() - 1):
			ui.description.text = "Reroll"
			ui.dps.text = ""
			ui.health.text = "$" + str(rerollPrice)
			ui.cost.text = ""
			ui.freeze.visible = false;
			ui.frozen.visible = false;
			ui.purchase.visible = true;
			ui.purchased.visible = false;
		else:
			if(current_display[current_item][2]):
				ui.freeze.visible = false;
				ui.frozen.visible = true;
			else:
				ui.freeze.visible = true;
				ui.frozen.visible = false;
				
			if(current_display[current_item][0] == null):
				ui.description.text = ""
				ui.dps.text = ""
				ui.health.text = ""
				ui.cost.text = ""
				ui.freeze.visible = false;
				ui.frozen.visible = false;
				ui.purchase.visible = false;
				ui.purchased.visible = true;
			else:
				ui.description.text = str(current_display[current_item][3])
				ui.dps.text = "DPS:" + str(current_display[current_item][4])
				ui.health.text = "HP:" + str(current_display[current_item][5])
				ui.cost.text = "$" + str(current_display[current_item][1])
				ui.purchase.visible = true;
				ui.purchased.visible = false;
		
		if Input.is_action_just_pressed("ui_right"):
			cameras[current_item].set_priority(0)
			swipe_SFX.play()
			current_item += 1
			current_item = current_item % cameras.size()
			cameras[current_item].set_priority(20)
			
		if Input.is_action_just_pressed("ui_left"):
			cameras[current_item].set_priority(0)
			swipe_SFX.play()
			current_item -= 1
			if(current_item < 0):
				current_item += cameras.size()
			cameras[current_item].set_priority(20)
			
		if Input.is_action_just_pressed("ui_up"):
			if current_item != cameras.size() - 1 && current_display[current_item][0] != null:
				if current_display[current_item][2]:
					steam_SFX.play()
				else:
					freeze_SFX.play()
				current_display[current_item][2] = !current_display[current_item][2]
				print(current_display)
				
		if Input.is_action_just_pressed("ui_down"):
			if current_item != cameras.size() - 1:
				if current_display[current_item][0] != null && Globals.coins - current_display[current_item][1] >= 0:
					Globals.coins -= current_display[current_item][1]
					purchase_SFX.play()
					current_display[current_item] = [null, 0, false, "", 0, 0]
					print(current_display)
			else:
				if Globals.coins - rerollPrice >= 0:
					Globals.coins -= rerollPrice
					dice_SFX.play()
					reroll(1)
					print(current_display)
					
		if Input.is_action_just_pressed("ui_cancel"):
			exit_shop()
			
func exit_shop() -> void:
	for cam: PhantomCamera3D in cameras:
		cam.set_priority(0)
	enter_SFX.play()
	Controls.lock_movement = false
	in_shop = false
	ui.shop.visible = false
	
func _on_area_3d_body_entered(_body: Node3D):
	if in_area == false:
		in_area = true
		in_shop = true
		enter_SFX.play()
		Controls.lock_movement = true
		cameras[0].set_priority(20)
		current_item = 0
		ui.shop.visible = true
		
func _on_area_3d_body_exited(_body: Node3D):
	in_area = false
	if in_shop:
		if GameCoordinator.current_room != GameCoordinator.Room.HUB:
			globals.character.camera.tween_parameters.duration = 0
		exit_shop()

func reroll(roundNum: int) -> void:
	var total = 0;
	for val in pool[roundNum].values():
		total += val[0]
	for i in range(current_display.size()):
		if(current_display[i][2] == true):
			continue
		var idx = rng.randi_range(1, total)
		var curRange = 0
		for key in pool[roundNum].keys():
			curRange += pool[roundNum][key][0]
			if idx <= curRange:
				current_display[i] = [key, pool[roundNum][key][1], false, "lorem ipsum", 1, 1]
				break
	
