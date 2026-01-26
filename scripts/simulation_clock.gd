extends Node

var time_scale := 60.0 # 1 real second = 1 simulated minute
var seconds := 0.0

signal time_changed(formatted_time)

func _process(delta):
	seconds += delta * time_scale
	emit_signal("time_changed", get_formatted_time())

func get_formatted_time() -> String:
	var total_minutes = int(seconds / 60.0)
	var hours = (total_minutes / 60) % 24
	var minutes = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]
