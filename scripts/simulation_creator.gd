extends Control

const ORANGE := Color(0.9529412, 0.54901963, 0.23921569)
const WHITE := Color(1.0, 1.0, 1.0)

var _font := preload("res://font/Orbitron-Bold.ttf")

var _name_input: LineEdit
var _time_scale_slider: HSlider
var _arrival_mult_slider: HSlider
var _arrival_rate_slider: HSlider
var _dwell_time_slider: HSlider
var _alight_ratio_slider: HSlider
var _train_cap_slider: HSlider
var _platform_cap_slider: HSlider
# { node_name: { "headway": HSlider, "speed": HSlider } }
var _line_controls: Dictionary = {}


func _ready() -> void:
	_build_ui()
	_prefill_from_config()


func _build_ui() -> void:
	# Background
	var bg := TextureRect.new()
	bg.texture = load("res://UI/bg.jpeg")
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Dark overlay matching the in-game aesthetic
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.01, 0.06, 0.80)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# Root VBoxContainer — fills screen with horizontal margins
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 100.0
	root.offset_right = -100.0
	root.offset_top = 28.0
	root.offset_bottom = -28.0
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	# Title
	var title := Label.new()
	title.text = "SIMULATION CREATOR"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", ORANGE)
	root.add_child(title)

	_add_separator(root, ORANGE)

	# Scrollable content area
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	scroll.add_child(content)

	_build_name_row(content)
	_add_section_header(content, "GLOBAL SETTINGS")
	_build_global_settings(content)
	_add_section_header(content, "LINE CONFIGURATION")
	_build_line_settings(content)
	_add_section_header(content, "STATION DEFAULTS")
	_build_station_defaults(content)
	_add_section_header(content, "TRAIN DEFAULTS")
	_build_train_defaults(content)
	_build_action_buttons(content)


func _prefill_from_config() -> void:
	var cfg := SimulationStore.current_config
	if cfg == null:
		return
	_time_scale_slider.value = cfg.time_scale
	_arrival_mult_slider.value = cfg.global_arrival_multiplier
	_arrival_rate_slider.value = cfg.default_arrival_rate
	_dwell_time_slider.value = cfg.default_dwell_time
	_alight_ratio_slider.value = cfg.default_alight_ratio
	_train_cap_slider.value = cfg.train_capacity
	_platform_cap_slider.value = cfg.default_platform_capacity
	for node_name: String in _line_controls:
		var lc: Dictionary = cfg.line_configs.get(node_name, {})
		if not lc.is_empty():
			_line_controls[node_name]["headway"].value = lc.get("headway", 180.0)
			_line_controls[node_name]["speed"].value = lc.get("speed_factor", 0.8)


# --- Section builders ---

func _build_name_row(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	parent.add_child(row)
	_add_field_label(row, "Simulation Name", 220)
	_name_input = LineEdit.new()
	_name_input.placeholder_text = "Enter name..."
	_name_input.text = "Simulation %d" % (SimulationStore.saved_simulations.size() + 1)
	_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_line_edit(_name_input)
	row.add_child(_name_input)


func _build_global_settings(parent: VBoxContainer) -> void:
	_time_scale_slider = _add_slider_row(
		parent, "Time Scale", 10.0, 300.0, 60.0, 10.0,
		func(v: float) -> String: return "%.0f x" % v
	)
	_arrival_mult_slider = _add_slider_row(
		parent, "Arrival Multiplier", 0.1, 5.0, 1.0, 0.1,
		func(v: float) -> String: return "%.1f x" % v
	)


func _build_line_settings(parent: VBoxContainer) -> void:
	for line_def: Dictionary in SimulationStore.LINE_REGISTRY:
		var node_name: String = line_def["node_name"]
		var col: Color = line_def["color"]

		var header := Label.new()
		header.text = "  — " + (line_def["display_name"] as String).to_upper()
		header.add_theme_font_override("font", _font)
		header.add_theme_font_size_override("font_size", 13)
		header.add_theme_color_override("font_color", col)
		parent.add_child(header)

		var headway_s := _add_slider_row(
			parent, "    Train Headway", 60.0, 600.0, 180.0, 10.0,
			func(v: float) -> String: return "%.0f s" % v
		)
		var speed_s := _add_slider_row(
			parent, "    Speed Factor", 0.2, 2.0, 0.8, 0.05,
			func(v: float) -> String: return "%.2f x" % v
		)
		_line_controls[node_name] = {"headway": headway_s, "speed": speed_s}

		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0, 4)
		parent.add_child(gap)


func _build_station_defaults(parent: VBoxContainer) -> void:
	_arrival_rate_slider = _add_slider_row(
		parent, "Arrival Rate", 1.0, 100.0, 10.0, 1.0,
		func(v: float) -> String: return "%.0f pax/min" % v
	)
	_dwell_time_slider = _add_slider_row(
		parent, "Dwell Time", 0.5, 15.0, 1.0, 0.5,
		func(v: float) -> String: return "%.1f s" % v
	)
	_alight_ratio_slider = _add_slider_row(
		parent, "Alight Ratio", 0.05, 0.95, 0.30, 0.05,
		func(v: float) -> String: return "%.0f%%" % (v * 100.0)
	)
	_platform_cap_slider = _add_slider_row(
		parent, "Platform Capacity", 100.0, 5000.0, 1000.0, 100.0,
		func(v: float) -> String: return "%.0f pax" % v
	)


func _build_train_defaults(parent: VBoxContainer) -> void:
	_train_cap_slider = _add_slider_row(
		parent, "Train Capacity", 100.0, 3000.0, 1000.0, 50.0,
		func(v: float) -> String: return "%.0f pax" % v
	)


func _build_action_buttons(parent: VBoxContainer) -> void:
	var top_gap := Control.new()
	top_gap.custom_minimum_size = Vector2(0, 24)
	parent.add_child(top_gap)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 48)
	parent.add_child(hbox)

	var back_btn := TextureButton.new()
	back_btn.texture_normal = load("res://UI/menu_orange_button.png")
	back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_btn.pressed.connect(_on_back_pressed)
	hbox.add_child(back_btn)

	var start_btn := TextureButton.new()
	start_btn.texture_normal = load("res://UI/start_blue_button.png")
	start_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	start_btn.pressed.connect(_on_start_pressed)
	hbox.add_child(start_btn)

	var bot_gap := Control.new()
	bot_gap.custom_minimum_size = Vector2(0, 24)
	parent.add_child(bot_gap)


# --- Widget helpers ---

func _add_slider_row(parent: VBoxContainer, label_text: String,
		min_v: float, max_v: float, default_v: float, step_v: float,
		formatter: Callable) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)

	_add_field_label(row, label_text, 220)

	var slider := HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.value = default_v
	slider.step = step_v
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_slider(slider)
	row.add_child(slider)

	var val_lbl := Label.new()
	val_lbl.text = formatter.call(default_v)
	val_lbl.custom_minimum_size = Vector2(110, 0)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val_lbl.add_theme_font_override("font", _font)
	val_lbl.add_theme_font_size_override("font_size", 13)
	val_lbl.add_theme_color_override("font_color", ORANGE)
	row.add_child(val_lbl)

	slider.value_changed.connect(func(v: float) -> void: val_lbl.text = formatter.call(v))
	return slider


func _add_field_label(parent: Control, text: String, min_width: int) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.custom_minimum_size = Vector2(min_width, 0)
	lbl.add_theme_font_override("font", _font)
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", WHITE)
	parent.add_child(lbl)


func _add_section_header(parent: VBoxContainer, text: String) -> void:
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 8)
	parent.add_child(gap)

	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", _font)
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", ORANGE)
	parent.add_child(lbl)

	_add_separator(parent, Color(ORANGE.r, ORANGE.g, ORANGE.b, 0.45))


func _add_separator(parent: VBoxContainer, color: Color) -> void:
	var sep := HSeparator.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0
	sep.add_theme_stylebox_override("separator", style)
	sep.custom_minimum_size = Vector2(0, 2)
	parent.add_child(sep)


func _style_slider(slider: HSlider) -> void:
	var groove := StyleBoxFlat.new()
	groove.bg_color = Color(0.08, 0.08, 0.18)
	groove.set_corner_radius_all(3)
	groove.content_margin_top = 6.0
	groove.content_margin_bottom = 6.0

	var fill := StyleBoxFlat.new()
	fill.bg_color = ORANGE
	fill.set_corner_radius_all(3)
	fill.content_margin_top = 6.0
	fill.content_margin_bottom = 6.0

	slider.add_theme_stylebox_override("slider", groove)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.custom_minimum_size = Vector2(0, 24)


func _style_line_edit(le: LineEdit) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.04, 0.04, 0.12, 0.92)
	normal.border_color = ORANGE
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	normal.content_margin_left = 8.0
	normal.content_margin_right = 8.0
	normal.content_margin_top = 6.0
	normal.content_margin_bottom = 6.0

	var focused := StyleBoxFlat.new()
	focused.bg_color = Color(0.06, 0.06, 0.18, 0.95)
	focused.border_color = Color(1.0, 0.82, 0.35)
	focused.set_border_width_all(2)
	focused.set_corner_radius_all(3)
	focused.content_margin_left = 8.0
	focused.content_margin_right = 8.0
	focused.content_margin_top = 6.0
	focused.content_margin_bottom = 6.0

	le.add_theme_stylebox_override("normal", normal)
	le.add_theme_stylebox_override("focus", focused)
	le.add_theme_color_override("font_color", WHITE)
	le.add_theme_color_override("font_placeholder_color", Color(0.45, 0.45, 0.55))
	le.add_theme_font_override("font", _font)
	le.add_theme_font_size_override("font_size", 14)


# --- Actions ---

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/simulation_selector.tscn")


func _on_start_pressed() -> void:
	var config := SimulationConfig.new()
	config.sim_id = SimulationStore._generate_id()
	var raw_name := _name_input.text.strip_edges()
	config.sim_name = raw_name if not raw_name.is_empty() \
		else "Simulation %d" % (SimulationStore.saved_simulations.size() + 1)
	config.created_at = Time.get_datetime_string_from_system()
	config.time_scale = _time_scale_slider.value
	config.global_arrival_multiplier = _arrival_mult_slider.value
	config.default_arrival_rate = _arrival_rate_slider.value
	config.default_dwell_time = _dwell_time_slider.value
	config.default_alight_ratio = _alight_ratio_slider.value
	config.default_platform_capacity = int(_platform_cap_slider.value)
	config.train_capacity = int(_train_cap_slider.value)

	for node_name: String in _line_controls:
		var ctrls: Dictionary = _line_controls[node_name]
		config.line_configs[node_name] = {
			"headway": ctrls["headway"].value,
			"speed_factor": ctrls["speed"].value,
		}

	SimulationStore.set_current(config)
	SimulationStore.save_simulation(config)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
