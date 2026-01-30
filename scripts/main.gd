extends Node2D

@onready var station_panel = $CanvasLayer/UIPanel

func _ready():
	connect_all_station_signals()

func connect_all_station_signals():
	for line in $Tracks.get_children():
		var stations_node = line.get_node("Stations")
		for station in stations_node.get_children():
			station.station_clicked.connect(_on_station_clicked)

func _on_station_clicked(station):
	station_panel.display_info_for(station)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if station_panel.visible:
			station_panel.hide()
