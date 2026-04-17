class_name SimulationConfig
extends RefCounted

var sim_id: String = ""
var sim_name: String = "New Simulation"
var created_at: String = ""

var time_scale: float = 60.0
var global_arrival_multiplier: float = 1.0
var default_arrival_rate: float = 10.0
var default_dwell_time: float = 1.0
var default_alight_ratio: float = 0.3
var default_platform_capacity: int = 1000
var train_capacity: int = 1000

# Keyed by MetroLine node name: { "headway": float, "speed_factor": float }
var line_configs: Dictionary = {}


func to_dict() -> Dictionary:
	return {
		"sim_id": sim_id,
		"sim_name": sim_name,
		"created_at": created_at,
		"time_scale": time_scale,
		"global_arrival_multiplier": global_arrival_multiplier,
		"default_arrival_rate": default_arrival_rate,
		"default_dwell_time": default_dwell_time,
		"default_alight_ratio": default_alight_ratio,
		"default_platform_capacity": default_platform_capacity,
		"train_capacity": train_capacity,
		"line_configs": line_configs,
	}


static func from_dict(d: Dictionary) -> SimulationConfig:
	var c := SimulationConfig.new()
	c.sim_id = d.get("sim_id", "")
	c.sim_name = d.get("sim_name", "New Simulation")
	c.created_at = d.get("created_at", "")
	c.time_scale = d.get("time_scale", 60.0)
	c.global_arrival_multiplier = d.get("global_arrival_multiplier", 1.0)
	c.default_arrival_rate = d.get("default_arrival_rate", 10.0)
	c.default_dwell_time = d.get("default_dwell_time", 1.0)
	c.default_alight_ratio = d.get("default_alight_ratio", 0.3)
	c.default_platform_capacity = d.get("default_platform_capacity", 1000)
	c.train_capacity = d.get("train_capacity", 1000)
	c.line_configs = d.get("line_configs", {})
	return c
