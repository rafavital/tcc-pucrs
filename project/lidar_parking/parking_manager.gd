extends Node3D
class_name ParkingSpotManager

const PARK_SPOT_GROUP = "park_spots"

@onready var available_spots := get_tree().get_nodes_in_group(PARK_SPOT_GROUP)


func get_available_park_spot () -> Node3D:
	if len(available_spots) > 0:
		var id = randi_range(0, len(available_spots) - 1)
		var spot = available_spots[id]
		available_spots.remove_at(id)
		return spot
	else:
		printerr("%s::No parking spots avaialble".format(self))
		return null

func release_park_spot (spot: Node3D) -> void:
	available_spots.push_back(spot)
