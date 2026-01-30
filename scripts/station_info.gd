extends VBoxContainer

@onready var station_name_label = $StationName
@onready var passengers_label = $Passengers
@onready var line_label = $Line
@onready var next_train_label = $NextTrain

func update_info(station):
	station_name_label.text = "Station: " + station.station_name
	passengers_label.text = "Passengers: " + str(station.waiting_passengers)
	line_label.text = "Line: " + station.line.name
	# next_train_label will need more logic, for now just a placeholder
	next_train_label.text = "Next Train: ..."
