extends VBoxContainer

@onready var train_name_label = $TrainName
@onready var passengers_label = $Passengers
@onready var line_label = $Line
@onready var next_station_label = $NextStation
@onready var speed_label = $Speed

func update_info(train):
	train_name_label.text = "Train: " + train.name
	passengers_label.text = "Passengers: " + str(train.passengers_on_board)
	line_label.text = "Line: " + train.line.name
	next_station_label.text = "Next Station: " + train.get_next_station_name()
	speed_label.text = "Speed: " + str(int(train.current_speed)) + " km/h"
