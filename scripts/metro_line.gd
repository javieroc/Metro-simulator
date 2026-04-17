extends Path2D
class_name MetroLine

@export var line_name: String = "Red Line"
@export var line_color: Color = Color.RED
@export var bidirectional := true
@export var train_scene: PackedScene
# --- Service configuration ---
@export var target_headway := 180.0 # seconds
@export var speed_factor := 0.8

signal train_spawned(train)

var stations := []
var trains := []
var pending_trains := 0
var dispatch_timer := 0.0

@onready var stations_container := $Stations

func _ready():
	var line_cfg := SimulationStore.get_line_config(name)
	if not line_cfg.is_empty():
		target_headway = line_cfg.get("headway", target_headway)
		speed_factor = line_cfg.get("speed_factor", speed_factor)

	await _wait_for_all_stations()
	spawn_trains()


func _process(delta):
	if pending_trains <= 0:
		return

	dispatch_timer += delta

	if dispatch_timer >= target_headway:
		dispatch_timer -= target_headway
		_dispatch_train()


func _wait_for_all_stations():
	while stations.size() < stations_container.get_child_count():
		await get_tree().process_frame


func calculate_required_trains() -> int:
	if not curve or target_headway <= 0:
		return 0

	var line_length := curve.get_baked_length()

	var base_speed := 20.0
	var actual_speed := base_speed * speed_factor

	if actual_speed <= 0:
		return 0

	var one_way_time := line_length / actual_speed
	var round_trip_time := one_way_time * (2.0 if bidirectional else 1.0)

	var trains_needed := int(ceil(round_trip_time / target_headway))
	return max(trains_needed, 1)


func spawn_trains():
	if not train_scene or stations.is_empty():
		return

	pending_trains = calculate_required_trains()
	dispatch_timer = target_headway # spawn first train immediately

	print("Line:", line_name, "Scheduled trains:", pending_trains)


func _dispatch_train():
	if pending_trains <= 0:
		return

	var train = train_scene.instantiate()
	train.line = self
	train.progress = 0.0 # always spawn at start

	add_child(train)

	trains.append(train)
	emit_signal("train_spawned", train)

	pending_trains -= 1


func register_station(station):
	stations.append(station)
	stations.sort_custom(func(a, b): return a.offset_on_path < b.offset_on_path)
	print("Line:", line_name, "Station:", station.station_name, "Total:", stations.size())


func register_train(train):
	trains.append(train)
