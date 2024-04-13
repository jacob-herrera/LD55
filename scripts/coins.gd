extends Label

func _process(_delta: float):
	self.text = "$" + str(global.coins)
