extends Node2D

@export var station_name: String
@export var dwell_time: float = 1.0
@export var platform_capacity: int = 1000
@export var radius := 20.0

var line: MetroLine
var offset_on_path: float = 0.0

func _ready():
	line = get_parent().get_parent() as MetroLine
	offset_on_path = line.curve.get_closest_offset(global_position)
	line.register_station(self)

func _draw():
	if line:
		draw_circle(Vector2.ZERO, radius, Color.BLACK)
		draw_circle(Vector2.ZERO, radius - 3, line.line_color)
