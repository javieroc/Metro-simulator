extends Path2D
class_name MetroLine

@export var line_name: String = "Red Line"
@export var line_color: Color = Color.RED
@export var bidirectional := true
@export var train_scene: PackedScene

signal train_spawned(train)

var stations := []
var trains := []

func spawn_train():
	if not train_scene or stations.is_empty():
		return

	var train = train_scene.instantiate()

	train.line = self
	train.progress = stations[0].offset_on_path

	add_child(train)

	trains.append(train)
	emit_signal("train_spawned", train)

func register_station(station):
	stations.append(station)
	stations.sort_custom(func(a, b): return a.offset_on_path < b.offset_on_path)
	print("Line:", line_name, "Station:", station.station_name, "Total:", stations.size())

func register_train(train):
	trains.append(train)
