extends HSlider

@export
var bus_name: String

var bus_idx: int

func _ready() -> void:
	bus_idx = AudioServer.get_bus_index(bus_name)
	_on_val_changed(value)
	value_changed.connect(_on_val_changed)

func _on_val_changed(val: float) -> void:
	val = remap(val, 0.0, 1.0, 0.0, 2.0)
	var db: float = linear_to_db(val)
	AudioServer.set_bus_volume_db(bus_idx, db)
