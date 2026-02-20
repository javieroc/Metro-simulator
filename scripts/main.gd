extends Node2D

const Train = preload("res://scripts/train.gd")

@onready var info_panel = $CanvasLayer/UIPanel

func _ready():
	connect_all_station_signals()
	for line in get_all_metro_lines():
		if not line.train_spawned.is_connected(_on_train_spawned):
			line.train_spawned.connect(_on_train_spawned)

func get_all_metro_lines() -> Array:
	var lines := []
	_collect_metro_lines($Tracks, lines)
	return lines

func _collect_metro_lines(node: Node, result: Array):
	for child in node.get_children():
		if child is MetroLine:
			result.append(child)
		else:
			_collect_metro_lines(child, result)

func connect_all_station_signals():
	for line in get_all_metro_lines():
		var stations_node = line.get_node_or_null("Stations")
		if not stations_node:
			continue
		for station in stations_node.get_children():
			if not station.station_clicked.is_connected(_on_station_clicked):
				station.station_clicked.connect(_on_station_clicked)

func _on_train_spawned(train):
	if not train.train_clicked.is_connected(_on_train_clicked):
		train.train_clicked.connect(_on_train_clicked)

func _on_station_clicked(station):
	info_panel.display_info_for(station)

func _on_train_clicked(train):
	print("Train clicked signal received in main.gd!")
	info_panel.display_info_for(train)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if info_panel.visible:
			info_panel.hide()
