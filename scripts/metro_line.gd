extends Path2D
class_name MetroLine

@export var line_name: String = "Red Line"
@export var line_color: Color = Color.RED
@export var bidirectional := true

var stations := []
var trains: Array = []

func register_station(station):
	stations.append(station)
	stations.sort_custom(func(a, b): return a.offset_on_path < b.offset_on_path)
	print("Line:", line_name, "Station:", station.station_name, "Total:", stations.size())

func register_train(train):
	trains.append(train)
