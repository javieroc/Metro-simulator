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
var direction := 1   # 1 forward, -1 backward

# --- Time ---
var dwell_timer := 0.0
var total_travel_time := 0.0

var bidirectional := true

func _ready():
	await get_tree().process_frame
	var line = get_parent() as Path2D
	stations = line.stations
	print("Stations loaded:", stations.size())

	current_station_index = 0
	next_station_index = 1
	progress = stations[0].offset_on_path


func _process(delta):
	total_travel_time += delta

	if waiting:
		dwell_timer -= delta
		if dwell_timer <= 0:
			waiting = false
		return

	var target_offset = stations[next_station_index].offset_on_path
	var distance = abs(target_offset - progress)

	var braking_distance = (current_speed * current_speed) / (2.0 * braking)

	if distance <= braking_distance:
		current_speed = move_toward(current_speed, 0, braking * delta)
	else:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)

	progress += current_speed * delta * direction

	if distance <= 1 or (current_speed < 5 and distance < 5):
		arrive_at_station()


func update_visual_direction():
	var target_rotation = $Sprite2D.rotation + PI  # rotate 180° from current

	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "rotation", target_rotation, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)


func arrive_at_station():
	waiting = true
	current_speed = 0

	# Snap exactly to platform center
	progress = stations[next_station_index].offset_on_path

	var station = stations[next_station_index]

	# --- Passenger flow (basic model) ---
	var alighting = int(passengers_on_board * 0.3)
	passengers_on_board -= alighting

	var boarding = min(station.platform_capacity, capacity - passengers_on_board)
	passengers_on_board += boarding

	# --- Dwell time ---
	dwell_timer = station.dwell_time

	# --- Advance routing with direction ---
	current_station_index = next_station_index
	next_station_index += direction

	if bidirectional:
		if next_station_index >= stations.size():
			next_station_index = stations.size() - 2
			direction = -1
			update_visual_direction()
		elif next_station_index < 0:
			next_station_index = 1
			direction = 1
			update_visual_direction()
	else:
		# Circular line
		if next_station_index >= stations.size():
			next_station_index = 0
