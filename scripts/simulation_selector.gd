extends Control

const ORANGE := Color(0.9529412, 0.54901963, 0.23921569)
const WHITE := Color(1.0, 1.0, 1.0)

var _font := preload("res://font/Orbitron-Bold.ttf")


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://UI/bg.jpeg")
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.01, 0.06, 0.80)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 100.0
	root.offset_right = -100.0
	root.offset_top = 28.0
	root.offset_bottom = -28.0
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var title := Label.new()
	title.text = "SELECT SIMULATION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", ORANGE)
	root.add_child(title)

	_add_separator(root, ORANGE)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

	_populate_list(content)
	_build_action_buttons(root)


func _populate_list(content: VBoxContainer) -> void:
	var sims: Array = SimulationStore.saved_simulations.duplicate()
	sims.reverse()

	if sims.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No simulations saved yet.\nCreate your first one below."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_lbl.add_theme_font_override("font", _font)
		empty_lbl.add_theme_font_size_override("font_size", 15)
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		content.add_child(empty_lbl)
		return

	for sim: SimulationConfig in sims:
		content.add_child(_create_sim_card(sim))


func _create_sim_card(sim: SimulationConfig) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 68)
	panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_style_card(panel, false)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	hbox.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = sim.sim_name
	name_lbl.add_theme_font_override("font", _font)
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", ORANGE)
	info.add_child(name_lbl)

	var meta := Label.new()
	meta.text = "Created: %s  •  Time scale: %.0fx  •  Arrival: %.1fx" % [
		sim.created_at, sim.time_scale, sim.global_arrival_multiplier
	]
	meta.add_theme_font_override("font", _font)
	meta.add_theme_font_size_override("font_size", 10)
	meta.add_theme_color_override("font_color", Color(0.65, 0.65, 0.72))
	info.add_child(meta)

	var arrow := Label.new()
	arrow.text = "▶"
	arrow.add_theme_font_size_override("font_size", 22)
	arrow.add_theme_color_override("font_color", ORANGE)
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(arrow)

	panel.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed \
				and event.button_index == MOUSE_BUTTON_LEFT:
			_start_with_config(sim)
	)
	panel.mouse_entered.connect(func() -> void: _style_card(panel, true))
	panel.mouse_exited.connect(func() -> void: _style_card(panel, false))

	return panel


func _style_card(panel: PanelContainer, hovered: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.15, 0.90) if not hovered \
		else Color(0.10, 0.10, 0.25, 0.95)
	style.border_color = ORANGE if not hovered else Color(1.0, 0.82, 0.35)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)


func _build_action_buttons(root: VBoxContainer) -> void:
	_add_separator(root, Color(ORANGE.r, ORANGE.g, ORANGE.b, 0.4))

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 48)
	root.add_child(hbox)

	var back_btn := TextureButton.new()
	back_btn.texture_normal = load("res://UI/menu_orange_button.png")
	back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_btn.pressed.connect(_on_back_pressed)
	hbox.add_child(back_btn)

	var new_btn := TextureButton.new()
	new_btn.texture_normal = load("res://UI/start_orange_button.png")
	new_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	new_btn.pressed.connect(_on_new_simulation_pressed)
	hbox.add_child(new_btn)


func _add_separator(parent: VBoxContainer, color: Color) -> void:
	var sep := HSeparator.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0
	sep.add_theme_stylebox_override("separator", style)
	sep.custom_minimum_size = Vector2(0, 2)
	parent.add_child(sep)


func _start_with_config(config: SimulationConfig) -> void:
	SimulationStore.set_current(config)
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/boot.tscn")


func _on_new_simulation_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/simulation_creator.tscn")
