extends Node

const SAVE_PATH := "user://simulations.json"

# Registry of all metro lines. Add a new entry here when adding a new line to main.tscn.
# node_name must match the exact Godot node name of the MetroLine Path2D in the scene.
const LINE_REGISTRY: Array = [
	{
		"node_name": "RedLine",
		"display_name": "Red Line",
		"color": Color(0.929, 0.106, 0.208),
		"default_headway": 180.0,
		"default_speed_factor": 0.8,
	},
	{
		"node_name": "BlueLine",
		"display_name": "Blue Line",
		"color": Color(0.0, 0.471, 0.749),
		"default_headway": 180.0,
		"default_speed_factor": 0.8,
	},
	{
		"node_name": "GreenLine",
		"display_name": "Green Line",
		"color": Color(0.267, 0.722, 0.361),
		"default_headway": 180.0,
		"default_speed_factor": 0.8,
	},
	{
		"node_name": "BrownLine",
		"display_name": "Circle Line",
		"color": Color(0.570, 0.279, 0.0),
		"default_headway": 180.0,
		"default_speed_factor": 0.8,
	},
	{
		"node_name": "LightBlueLineB1",
		"display_name": "Light Blue B1",
		"color": Color(0.098, 0.757, 0.953),
		"default_headway": 180.0,
		"default_speed_factor": 0.8,
	},
	{
		"node_name": "LightBlueLineB2",
		"display_name": "Light Blue B2",
		"color": Color(0.098, 0.757, 0.953),
		"default_headway": 180.0,
		"default_speed_factor": 0.8,
	},
]

var current_config: SimulationConfig = null
var saved_simulations: Array = []


func _ready() -> void:
	load_from_disk()
	if current_config == null:
		current_config = _make_default_config()


func _make_default_config() -> SimulationConfig:
	var c := SimulationConfig.new()
	c.sim_id = _generate_id()
	c.sim_name = "Default"
	c.created_at = Time.get_datetime_string_from_system()
	for line_def: Dictionary in LINE_REGISTRY:
		c.line_configs[line_def["node_name"]] = {
			"headway": line_def["default_headway"],
			"speed_factor": line_def["default_speed_factor"],
		}
	return c


func get_line_config(node_name: String) -> Dictionary:
	if current_config == null:
		return {}
	return current_config.line_configs.get(node_name, {})


func set_current(config: SimulationConfig) -> void:
	current_config = config


func save_simulation(config: SimulationConfig) -> void:
	for i in saved_simulations.size():
		if saved_simulations[i].sim_id == config.sim_id:
			saved_simulations[i] = config
			save_to_disk()
			return
	saved_simulations.append(config)
	save_to_disk()


func save_to_disk() -> void:
	var data: Array = []
	for s: SimulationConfig in saved_simulations:
		data.append(s.to_dict())
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()


func load_from_disk() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed is Array:
		saved_simulations.clear()
		for d in parsed:
			if d is Dictionary:
				saved_simulations.append(SimulationConfig.from_dict(d))


func _generate_id() -> String:
	return str(int(Time.get_unix_time_from_system())) + "_" + str(randi() % 100000)
