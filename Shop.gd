extends StaticBody3D
@export var cameras: Array[PhantomCamera3D]
@export var character: Character

var curItem = 0
var total = 3
var inShop = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if inShop == true:
		if Input.is_action_just_pressed("ui_right"):
			cameras[curItem].set_priority(0)
			curItem += 1
			curItem = curItem % total
			cameras[curItem].set_priority(20)
		if Input.is_action_just_pressed("ui_left"):
			cameras[curItem].set_priority(0)
			curItem -= 1
			curItem = curItem % total
			cameras[curItem].set_priority(20)
		if Input.is_action_just_pressed("ui_cancel"):
			inShop = false
			

func _on_area_3d_body_entered(body):
	print("Entered Shop")
	inShop = true
	cameras[0].set_priority(20)
	

func _on_area_3d_body_exited(body):
	print("Exited Shop")
