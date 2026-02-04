extends Node2D

const Train = preload("res://scripts/train.gd")
@onready var info_panel = $CanvasLayer/UIPanel

func _ready():
	connect_all_station_signals()

	for line_node in $Tracks.get_children():
		var line := line_node as MetroLine
		if not line:
			continue

		if not line.train_spawned.is_connected(_on_train_spawned):
			line.train_spawned.connect(_on_train_spawned)

func connect_all_station_signals():
	for line in $Tracks.get_children():
		var stations_node = line.get_node("Stations")
		for station in stations_node.get_children():
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
