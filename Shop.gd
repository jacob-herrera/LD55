extends StaticBody3D
@export var cameras: Array[PhantomCamera3D]
@export var character: Character

var curItem = 0
var total = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

func _on_area_3d_body_entered(body):
	print("entered shop")
	cameras[0].set_priority(20)
	

func _on_area_3d_body_exited(body):
	print("exited shop")
	cameras[0].set_priority(0)
	print(cameras[0].get_priority())
