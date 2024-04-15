extends Label

func _process(delta):
	self.text = str(globals.mana) + "/" + str(globals.max_mana)

#func update():
#	value = global.mana 
