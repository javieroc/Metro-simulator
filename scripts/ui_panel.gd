extends NinePatchRect

@onready var station_name_label = $VBoxContainer/StationName
@onready var passengers_label = $VBoxContainer/Passengers
@onready var line_label = $VBoxContainer/Line
@onready var next_train_label = $VBoxContainer/NextTrain

func _ready():
	pass # NinePatchRect will size itself based on its content and size flags

func update_info(station):
	if station:
		station_name_label.text = "Station: " + station.station_name
		passengers_label.text = "Passengers: " + str(station.waiting_passengers)
		line_label.text = "Line: " + station.line.name
		next_train_label.text = "Next Train: Calculating..."
		
		# Set the desired width (1/6 of viewport width)
		var target_width = get_viewport_rect().size.x / 6
		
		# Calculate the required height of the VBoxContainer with its current content
		var vbox_min_size = $VBoxContainer.get_minimum_size()
		
		# Add padding for the NinePatchRect's borders
		var panel_content_width = vbox_min_size.x + patch_margin_left + patch_margin_right
		var panel_content_height = vbox_min_size.y + patch_margin_top + patch_margin_bottom
		
		# Set the NinePatchRect's size
		custom_minimum_size = Vector2(target_width, panel_content_height)
		size = custom_minimum_size
		
		show()
	else:
		hide()

func set_next_train_label(text):
	next_train_label.text = "Next Train: " + text
