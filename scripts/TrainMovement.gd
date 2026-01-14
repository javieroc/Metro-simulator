extends PathFollow2D

@export var max_speed := 300.0   # Pixels per second
@export var acceleration := 150.0
@export var station_wait_time := 2.0

var current_speed := 0.0
var target_speed := 100.0
var is_waiting := false

func _process(delta):
	if is_waiting:
		return

	# Simple acceleration logic
	current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	
	# Move along the path
	progress += current_speed * delta

	# Check for end of line (Looping logic)
	if progress_ratio >= 1.0:
		progress_ratio = 0.0 # Reset to start for now
