extends NinePatchRect

@onready var station_name_label = $VBoxContainer/StationName
@onready var passengers_label = $VBoxContainer/Passengers
@onready var line_label = $VBoxContainer/Line
@onready var next_train_label = $VBoxContainer/NextTrain

func _ready():
	# This panel's size is controlled by the update_info() function.
	pass


# This function uses 'await' to pause execution and wait for the layout to update after changing the panel width.
# This ensures the height is calculated based on the correct width, resolving issues with text wrapping and panel size.
func update_info(station):
	if station:
		station_name_label.text = "Station: " + station.station_name
		passengers_label.text = "Passengers: " + str(station.waiting_passengers)
		line_label.text = "Line: " + station.line.name
		next_train_label.text = "Next Train: Calculating..."

		# Set the desired width (1/6 of viewport width)
		var target_width = get_viewport_rect().size.x / 6

		# Set the width first, so the child controls can reflow.
		size.x = target_width

		# Wait one frame for the layout system to update the VBoxContainer's geometry
		# based on the new width of this NinePatchRect.
		await get_tree().process_frame

		# Now that layout is updated, calculate the required height of the VBoxContainer.
		var vbox_min_size = $VBoxContainer.get_minimum_size()

		# Add padding for the NinePatchRect's borders.
		var panel_content_height = vbox_min_size.y + patch_margin_top + patch_margin_bottom

		# Set the NinePatchRect's final size.
		custom_minimum_size = Vector2(target_width, panel_content_height)
		size = custom_minimum_size

		show()
	else:
		hide()

func set_next_train_label(text):
	next_train_label.text = "Next Train: " + text
