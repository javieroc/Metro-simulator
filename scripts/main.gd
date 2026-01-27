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
	show_station_panel(station)

func show_station_panel(station):
	station_panel.update_info(station)
	var screen_pos = get_viewport().get_canvas_transform() * station.global_position
	station_panel.position = screen_pos + Vector2(30, -station_panel.size.y * 0.5)
	station_panel.show()
