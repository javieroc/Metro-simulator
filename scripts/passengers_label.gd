extends Label

@export var update_interval := 1.0 # real seconds

var _timer := 0.0

func _process(delta):
	_timer += delta
	if _timer >= update_interval:
		_timer = 0.0
		text = "Passengers: %d" % Clock.total_passengers
