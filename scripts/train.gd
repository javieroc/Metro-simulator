extends PathFollow2D

# --- Physical parameters ---
@export var max_speed := 300.0
@export var acceleration := 200.0
@export var braking := 300.0

# --- Capacity & passengers ---
@export var capacity := 1000
var passengers_on_board := 0

# --- Line & routing ---
var stations := []
var current_station_index := 0
var next_station_index := 1

# --- State ---
var current_speed := 0.0
var waiting := false
var direction := 1   # 1 forward, -1 backward (future)

# --- Time ---
var dwell_timer := 0.0
var total_travel_time := 0.0

func _ready():
	await get_tree().process_frame
	var line = get_parent() as Path2D
	stations = line.stations
	print("Stations loaded:", stations.size())

	progress = stations[0].offset_on_path

func _process(delta):
	if waiting:
		return

	var target_offset = stations[current_station_index].offset_on_path
	var distance = target_offset - progress

	var braking_distance = (current_speed * current_speed) / (2.0 * braking)

	if distance <= braking_distance:
		current_speed = move_toward(current_speed, 0, braking * delta)
	else:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)

	progress += current_speed * delta

	# Snap-to-platform condition
	if distance <= 0 or (current_speed < 5 and distance < 5):
		arrive_at_station()

func arrive_at_station():
	waiting = true
	current_speed = 0

	# Snap exactly to station
	progress = stations[current_station_index].offset_on_path

	var station = stations[current_station_index]
	await get_tree().create_timer(station.dwell_time).timeout

	current_station_index += 1
	if current_station_index >= stations.size():
		current_station_index = 1
		progress = stations[0].offset_on_path

	waiting = false
