extends Path2D

var stations := []

func register_station(station):
	stations.append(station)
	stations.sort_custom(func(a, b): return a.offset_on_path < b.offset_on_path)
	print("Registered station:", station.station_name, "Total:", stations.size())
