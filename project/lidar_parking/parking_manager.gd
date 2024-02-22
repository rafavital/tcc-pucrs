extends Node3D
class_name ParkingSpotManager

const PARK_SPOT_GROUP = "park_spots"

@onready var available_spots := get_tree().get_nodes_in_group(PARK_SPOT_GROUP)


func get_available_park_spot () -> Node3D:
	if len(available_spots) > 0:
		return available_spots.pop_front()
	else:
		printerr("%s::No parking spots avaialble".format(self))
		return null

func release_park_spot (spot: Node3D) -> void:
	available_spots.push_back(spot)
