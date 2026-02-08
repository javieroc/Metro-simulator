extends Label

func _ready():
	Clock.time_changed.connect(_on_time_changed)
	text = "Time: " + Clock.get_formatted_time()

func _on_time_changed(new_time: String):
	text = "Time: " + new_time
