extends Node2D

signal station_clicked(station)

@export var station_name: String
@export var dwell_time: float = 1.0
@export var platform_capacity: int = 1000
@export var radius := 20.0

# Passenger model (Poisson λ per minute)
@export var arrival_rate_per_minute: float = 120.0
var waiting_passengers: int = 0

var line: MetroLine
var offset_on_path: float = 0.0

func _ready():
	station_name = name
	line = get_parent().get_parent() as MetroLine
	offset_on_path = line.curve.get_closest_offset(global_position)
	line.register_station(self)
	
	var shape :=  $Area2D/CollisionShape2D.shape as CircleShape2D
	shape.radius = radius + 4
	
	$Area2D.input_event.connect(_on_input_event)

func _draw():
	if line:
		draw_circle(Vector2.ZERO, radius, Color.BLACK)
		draw_circle(Vector2.ZERO, radius - 3, line.line_color)

func _process(delta):
	generate_passengers(delta)

func generate_passengers(delta):
	# Convert λ from per-minute to per-second
	var lambda_per_second = arrival_rate_per_minute / 60.0
	var expected = lambda_per_second * delta

	var new_passengers = poisson_sample(expected)
	waiting_passengers += new_passengers

	# Cap by platform capacity
	waiting_passengers = min(waiting_passengers, platform_capacity)

func poisson_sample(mean: float) -> int:
	var L = exp(-mean)
	var k = 0
	var p = 1.0
	while p > L:
		k += 1
		p *= randf()
	return k - 1


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("station_clicked", self)
