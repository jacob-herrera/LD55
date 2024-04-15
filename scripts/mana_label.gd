extends Label

func _process(delta):
	self.text = str(global.mana) + "/" + str(globals.max_mana)

#func update():
#	value = global.mana 
