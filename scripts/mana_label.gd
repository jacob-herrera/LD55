extends Label

func _process(delta):
	self.text = str(global.mana) + "/" + str(global.max_mana)

#func update():
#	value = global.mana 
