extends Node3D
class_name AIController3D

@export var reset_after := 1000

var heuristic := "human"
var done := false
var reward := 0.0
var n_steps := 0
var needs_reset := false

var _player: Node3D

var move = Vector2.ZERO

@onready var agent = $".."
@onready var target = $"../../Target"

func _ready():
	add_to_group("AGENT")
	
func init(player: Node3D):
	_player = player
	
#-- Methods that need implementing using the "extend script" option in Godot --#
func get_obs() -> Dictionary:
	var obs := [
		agent.position.x,
		agent.position.z,
		target.position.x,
		target.position.z
	]
	
	return {"obs":obs}

func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"move" : {
			"size": 2,
			"action_type": "continuous"
		},
	}
	
func set_action(action) -> void:	
	move.x = action["move"][0]
	move.y = action["move"][1]
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
