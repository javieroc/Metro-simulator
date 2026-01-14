extends Camera2D

@export var map_path: NodePath = "../MapLayer/TextureRect"
@export var pan_speed := 1200.0
@export var zoom_speed := 0.05
@export var min_zoom_factor := 0.2  # How far you can zoom in
@export var smoothing := 15.0

var target_position: Vector2
var target_zoom: Vector2
var map_size: Vector2
var max_zoom_out: float = 1.0

func _ready():
	var map_node = get_node(map_path) as TextureRect
	if map_node:
		map_size = map_node.get_rect().size
		# Wait one frame to ensure viewport size is initialized
		await get_tree().process_frame
		_fit_map_to_screen()
	
	target_position = position
	target_zoom = zoom

func _fit_map_to_screen():
	var view_size = get_viewport_rect().size
	# Calculate the zoom level needed to see the whole map
	var zoom_x = view_size.x / map_size.x
	var zoom_y = view_size.y / map_size.y
	max_zoom_out = min(zoom_x, zoom_y)
	
	zoom = Vector2(max_zoom_out, max_zoom_out)
	target_zoom = zoom
	# Center the camera on the map
	position = map_size / 2.0
	target_position = position

func _input(event):
	# 1. TOUCHPAD PAN (Two fingers)
	if event is InputEventPanGesture:
		target_position += event.delta * (pan_speed / zoom.x)

	# 2. TOUCHPAD MAGNIFY (Pinch to zoom)
	if event is InputEventMagnifyGesture:
		_apply_zoom(event.factor - 1.0)

	# 3. CTRL + DRAG (Mouse/Touchpad) to Zoom
	if event is InputEventMouseMotion and Input.is_key_pressed(KEY_CTRL):
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# Vertical drag while holding Ctrl zooms in/out
			_apply_zoom(-event.relative.y * 0.01)

	# 4. TRADITIONAL DRAG (Middle Mouse or Touchpad Click-Drag)
	if event is InputEventScreenDrag or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_key_pressed(KEY_CTRL)):
		target_position -= event.relative / zoom.x

	# 5. MOUSE WHEEL ZOOM
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-zoom_speed)

func _apply_zoom(delta):
	var new_zoom = target_zoom.x + delta
	# Limit zoom: max_zoom_out is the whole map, 2.0 is usually close enough for text
	new_zoom = clamp(new_zoom, max_zoom_out, 2.0)
	target_zoom = Vector2(new_zoom, new_zoom)

func _process(delta):
	# Handle Arrows
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	target_position += input_dir * (pan_speed * delta) / zoom.x

	# BOUNDARY CLAMPING
	var screen_size = get_viewport_rect().size / zoom.x
	limit_left = screen_size.x / 2.0
	limit_right = map_size.x - (limit_left)
	limit_top = screen_size.y / 2.0
	limit_bottom = map_size.y - (limit_top)

	# If map is smaller than screen (zoomed out far), keep it centered
	if limit_right < limit_left:
		target_position.x = map_size.x / 2.0
	else:
		target_position.x = clamp(target_position.x, limit_left, limit_right)
		
	if limit_bottom < limit_top:
		target_position.y = map_size.y / 2.0
	else:
		target_position.y = clamp(target_position.y, limit_top, limit_bottom)

	# Smooth interpolation
	position = position.lerp(target_position, smoothing * delta)
	zoom = zoom.lerp(target_zoom, smoothing * delta)
