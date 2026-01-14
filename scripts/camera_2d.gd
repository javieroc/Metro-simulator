extends Camera2D

@export var map_path: NodePath = "../MapLayer/TextureRect"
@export var pan_speed := 1200.0
@export var smoothing := 15.0
@export var min_zoom := 0.2
@export var max_zoom := 2.0

var target_position: Vector2
var target_zoom: Vector2
var map_size: Vector2
var max_zoom_out: float = 1.0

# Mobile/Multitouch variables
var last_pinch_distance: float = 0.0
var is_pinching: bool = false

func _ready():
	var map_node = get_node(map_path) as TextureRect
	if map_node:
		map_size = map_node.get_rect().size
		await get_tree().process_frame
		_fit_map_to_screen()
	
	target_position = position
	target_zoom = zoom

func _fit_map_to_screen():
	var view_size = get_viewport_rect().size
	var zoom_x = view_size.x / map_size.x
	var zoom_y = view_size.y / map_size.y
	max_zoom_out = min(zoom_x, zoom_y)
	
	target_zoom = Vector2(max_zoom_out, max_zoom_out)
	zoom = target_zoom
	target_position = map_size / 2.0
	position = target_position

func _input(event):
	# 1. PC: MOUSE WHEEL & CTRL+DRAG ZOOM
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(0.1, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-0.1, event.position)

	if event is InputEventMouseMotion and Input.is_key_pressed(KEY_CTRL) and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_apply_zoom(-event.relative.y * 0.01, get_viewport().get_mouse_position())

	# 2. TOUCHPAD (Laptop) Gestures
	if event is InputEventMagnifyGesture:
		_apply_zoom(event.factor - 1.0, get_viewport().get_mouse_position())
	if event is InputEventPanGesture:
		target_position += event.delta * (pan_speed / zoom.x)

	# 3. MOBILE: MULTI-TOUCH PINCH ZOOM
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var touches = Input.get_last_mouse_velocity() # Just a placeholder check
		# Note: For perfect mobile pinch, Godot 4 uses 'Input.is_action_pressed' 
		# with specific touch indices, but standard ScreenDrag handles 1-finger pan:
		if event is InputEventScreenDrag and not is_pinching:
			target_position -= event.relative / zoom.x

	# 4. TRADITIONAL DRAG (Left click)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_key_pressed(KEY_CTRL):
		target_position -= event.relative / zoom.x

func _apply_zoom(delta, zoom_anchor):
	# 1. Store the world position of the mouse BEFORE zooming
	var old_mouse_pos = get_global_mouse_position()

	# 2. Apply the zoom change
	var old_zoom = target_zoom.x
	target_zoom.x = clamp(target_zoom.x + delta, max_zoom_out, max_zoom)
	target_zoom.y = target_zoom.x

	# 3. If zoom didn't actually change (already at min/max), don't move camera
	if old_zoom == target_zoom.x:
		return

	# 4. Calculate where the mouse WOULD BE in the world after the zoom
	# We use the ratio of the zoom change to shift the target_position
	# This 'anchors' the zoom to the mouse cursor
	var zoom_ratio = target_zoom.x / old_zoom
	target_position = old_mouse_pos + (target_position - old_mouse_pos) / (target_zoom.x / old_zoom)

func _process(delta):
	# Handle Arrows
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	target_position += input_dir * (pan_speed * delta) / zoom.x

	# BOUNDARY CLAMPING
	# Use target_zoom for calculations to ensure limits update while zooming
	var curr_v_size = get_viewport_rect().size / target_zoom.x

	var limit_left = curr_v_size.x / 2.0
	var limit_right = map_size.x - limit_left
	var limit_top = curr_v_size.y / 2.0
	var limit_bottom = map_size.y - limit_top

	# Clamp X
	if limit_right < limit_left:
		target_position.x = map_size.x / 2.0
	else:
		target_position.x = clamp(target_position.x, limit_left, limit_right)

	# Clamp Y
	if limit_bottom < limit_top:
		target_position.y = map_size.y / 2.0
	else:
		target_position.y = clamp(target_position.y, limit_top, limit_bottom)

	# Smooth interpolation
	position = position.lerp(target_position, smoothing * delta)
	zoom = zoom.lerp(target_zoom, smoothing * delta)
