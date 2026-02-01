extends NinePatchRect

const StationInfo = preload("res://scenes/station_info.tscn")
const TrainInfo = preload("res://scenes/train_info.tscn")

@onready var content_container = $ContentContainer
var current_content = null

func display_info_for(target):
	# Clear previous content
	if current_content:
		current_content.queue_free()
		current_content = null

	# Check the type of the target and instantiate the correct info panel
	if "station_name" in target: # Duck typing to check if it's a station
		current_content = StationInfo.instantiate()
	elif "max_speed" in target: # For trains later
		current_content = TrainInfo.instantiate()
	else:
		print("Unknown target for UIPanel: ", target)
		return

	content_container.add_child(current_content)
	current_content.update_info(target)

	# --- Sizing ---
	var target_width = get_viewport_rect().size.x / 6
	size.x = target_width
	await get_tree().process_frame
	var vbox_min_size = content_container.get_minimum_size()
	var panel_content_height = vbox_min_size.y + patch_margin_top + patch_margin_bottom
	custom_minimum_size = Vector2(target_width, panel_content_height)
	size = custom_minimum_size

	# --- Positioning ---
	var screen_pos = get_viewport().get_canvas_transform() * target.global_position
	position = screen_pos + Vector2(30, -size.y * 0.5)

	show()
