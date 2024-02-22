extends Node3D
class_name CarAIController

@export var reset_after := 1000

var heuristic := "human"
var done := false
var reward := 0.0
var n_steps := 0
var needs_reset := false

var _car: VehicleBody3D
var _park_spot : Node3D

var engine_force := 0.0
var steering := 0.0

@onready var sensors = $Sensors

func _ready():
	add_to_group("AGENT")
	
func init(car: VehicleBody3D, park_spot : Node3D):
	_car = car
	_park_spot = park_spot
	
#-- Methods that need implementing using the "extend script" option in Godot --#
func get_obs() -> Dictionary:
	var obs := [
		_car.position.x,
		_car.position.y,
		_park_spot.position.x,
		_park_spot.position.y
	]
	
	obs.append(sensors.get_observation())
	
	return {"obs":obs}

func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"engine_force": {
			"size":1,
			"action_type":"continuous"
		},
		"steering": {
			"size" : 1,
			"action_type": "continuous"
		},
	}
	
func set_action(action) -> void:	
	engine_force = clampf(action["engine_force"][0], -1.0, 1.0)
	steering = clampf(action["steering"][0], -1.0, 1.0)
	# move.x = action["move"][0]
	# move.y = action["move"][1]
# -----------------------------------------------------------------------------#
	
func _physics_process(delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
		
func get_obs_space():
	# may need overriding if the obs space is complex
	var obs = get_obs()
	return {
		"obs": {
			"size": [len(obs["obs"])],
			"space": "box"
		},
	}

func reset():
	n_steps = 0
	needs_reset = false

func reset_if_done():
	if done:
		reset()
		
func set_heuristic(h):
	# sets the heuristic from "human" or "model" nothing to change here
	heuristic = h

func get_done():
	return done
	
func set_done_false():
	done = false

func zero_reward():
	reward = 0.0
