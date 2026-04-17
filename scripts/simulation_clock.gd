extends Node

var time_scale := 60.0
var seconds := 0.0
var total_passengers := 0

signal time_changed(formatted_time)
signal passengers_changed(total_passengers)

func _ready() -> void:
	var cfg := SimulationStore.current_config
	if cfg:
		time_scale = cfg.time_scale


func _process(delta):
	seconds += delta * time_scale
	emit_signal("time_changed", get_formatted_time())

func add_passengers(count: int):
	if count <= 0:
		return
	total_passengers += count
	emit_signal("passengers_changed", total_passengers)

func remove_passengers(count: int):
	if count <= 0:
		return
	total_passengers -= count
	total_passengers = max(total_passengers, 0)
	emit_signal("passengers_changed", total_passengers)

func get_formatted_time() -> String:
	var total_minutes = int(seconds / 60.0)
	var hours = (total_minutes / 60) % 24
	var minutes = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]
