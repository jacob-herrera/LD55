extends Node
class_name Globals

var character: Character
var highlight: Sprite3D
var lives: int = 3

const GROUND_LAYER: int = 1
const SUMMON_MANA_COST: int = 15

static var coins: int = 33
static var mana: int = 60:
	set(new_value):
		mana = new_value
		if mana < SUMMON_MANA_COST:
			ui.middle_container.modulate = Color(1,1,1,0.5)
		else:
			ui.middle_container.modulate = Color(1,1,1,1)
	
static var max_mana: int = 60
static var is_in_shop: bool = false
static var is_in_summon_ui: bool = false



func _process(_delta: float) -> void:
	var all_found: bool = true
	if not is_instance_valid(highlight):
		var node: Node = get_tree().current_scene.find_child("HighlightArrow")
		if is_instance_valid(node):
			highlight = node as Sprite3D
		else:
			all_found = false
	if all_found:
		set_process(false)
			
func set_highlight_pos(pos: Vector3) -> void:
	if is_instance_valid(highlight):
		highlight.global_position = pos
