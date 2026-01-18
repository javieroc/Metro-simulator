extends Node2D

@export var station_name: String
@export var dwell_time: float = 1.0
@export var platform_capacity: int = 1000

var path: Path2D
var offset_on_path: float = 0.0

func snap_to_path(p: Path2D):
	path = p
	offset_on_path = path.curve.get_closest_offset(global_position)

func _ready():
	snap_to_path(get_node("/root/Main/Tracks/RedLine"))
	path.register_station(self)
