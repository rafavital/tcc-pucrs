extends VehicleBody3D

static var _car_colors = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW]

signal engine_force_changed(value :float)
signal steering_changed (value:float)
signal reward_changed(value:float)

#const PARK_SPOT_GROUP := "park_spots"
const GOAL_RADIUS := 2.0
const PLAYING_AREA_RADIUS := 10.0
const PARK_DIST_THRESHOLD := 0.5
const PARK_DIR_THRESHOLD := 0.07
const PARK_VEL_THRESHOLD := 0.05

const REWARD_PARKED := 10
const REWARD_OUT_OF_BOUNDS := -10
const REWARD_COLLISION := -30
const REWARD_CLOSING_IN := 5

const PLAYING_AREA_X_SIZE := 20.0
const PLAYING_AREA_Y_SIZE := 20.0

const PLAYING_AREA_SIZE := Vector2(20,20)

@export var acceleration: float = 200
@export var braking : float = 200
@export var max_steer_angle: float = 20
@export var color := Color.GRAY

var _park_spot : Node3D
var _smallest_distance_to_goal : float
var _times_restarted := 0

@onready var _max_possible_distance := PLAYING_AREA_SIZE.length()
@onready var _initial_position := position
@onready var _initial_transform := transform
#@onready var _parking_manager : ParkingSpotManager = get_node("/root/ParkingManager")
@onready var body = %body
@onready var spot_indicator = get_node("SpotIndicator")

# Called when the node enters the scene tree for the first time.
func _ready():
	#var surface_id = body.mesh.surface_find_by_name("paintRed")
	#body.mesh.surface_get_material(surface_id).albedo_color = color
	_get_new_spot()
	%CarAIController.init(self, _park_spot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_check_for_reset()
	_update_reward()
	
	engine_force = %CarAIController.engine_force * acceleration
	brake = %CarAIController.brake * braking
	steering = move_toward(steering, deg_to_rad(%CarAIController.steering * max_steer_angle), delta)
	
	_broadcast_values()
	_check_if_parked()
	#engine_force = Input.get_axis("ui_up", "ui_down") * acceleration
	#steering = deg_to_rad(Input.get_axis("ui_left", "ui_right") * -max_steer_angle)
	
	
func reset():
	_times_restarted += 1
	#%CarAIController.reward = Vector2(position.x, position.z).distance_to(Vector2(_park_spot.position.x, _park_spot.position.z))
	%CarAIController.reset()
	#position = _initial_position
	transform = _initial_transform
	_smallest_distance_to_goal = _get_current_distance_to_goal()
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	#_get_new_spot()
	# reset position
	# get another parking position	

func _update_reward():
	if _times_restarted == 0:
		return
		
	var distance = _get_current_distance_to_goal()
	var reward = 0.0
	
	var orientation_modifier := 1.0
	
	#reward = _smallest_distance_to_goal - distance
	
	if distance < GOAL_RADIUS:
		orientation_modifier = (1 - _get_direction_difference())
	
	if distance < _smallest_distance_to_goal:
		%CarAIController.reward +=  (_smallest_distance_to_goal - distance) * REWARD_CLOSING_IN * orientation_modifier
		_smallest_distance_to_goal = distance
	elif distance > GOAL_RADIUS:
		%CarAIController.reward +=  -10 * (_get_normalized_velocity().length() / %CarAIController.reset_after)
	
	# Punishment if the car runs from the goal
	if _smallest_distance_to_goal < GOAL_RADIUS and distance > _smallest_distance_to_goal + GOAL_RADIUS:
		_end_episode(REWARD_OUT_OF_BOUNDS)	
	
	%CarAIController.reward += reward
		

func _check_if_parked():
	var dist = _get_current_distance_to_goal()
	if (	dist < PARK_DIST_THRESHOLD and 
			_get_direction_difference() < PARK_DIR_THRESHOLD and 
			linear_velocity.length() < PARK_VEL_THRESHOLD):
		_successfully_parked_end_episode()

func _check_for_reset():
	if %CarAIController.needs_reset:
		reset()

func on_out_of_bounds () -> void :
	_end_episode(REWARD_OUT_OF_BOUNDS)
	

func _get_new_spot () -> void:
	if _park_spot != null:
		ParkingManager.release_park_spot(_park_spot)
	
	_park_spot = ParkingManager.get_available_park_spot()
	if spot_indicator:
		spot_indicator.reparent(get_tree().root.get_child(0))
		spot_indicator.global_position = _park_spot.global_transform.origin + Vector3.UP * 5

func _successfully_parked_end_episode() -> void:
	var reward = (
		REWARD_PARKED
		- _get_direction_difference() * 4
		- (float(%CarAIController.n_steps) / %CarAIController.reset_after) * 2
		- _get_normalized_velocity().length()
		#- (goal_dist / _max_goal_dist)
	)
	_end_episode(REWARD_PARKED)

func _end_episode (final_reward: float):
	%CarAIController.reward += final_reward
	%CarAIController.needs_reset = true
	%CarAIController.done = true


func get_normalized_goal_pos():
	return to_local(_park_spot.transform.origin)/ _max_possible_distance

func _get_current_distance_to_goal() -> float:
	# Exclude Y difference from the calculated distance 
	var goal_transform: Transform3D = _park_spot.transform
	goal_transform.origin.y = global_position.y
	return goal_transform.origin.distance_to(global_position)


func _broadcast_values() ->void:
	emit_signal("reward_changed", %CarAIController.reward)
	emit_signal("steering_changed", steering)
	emit_signal("engine_force_changed", engine_force)
	
# Returns the difference between current direction and goal direction in range 0,1
# If 1, the angle is 180 degrees, if 0, the direction is perfectly aligned.
func _get_direction_difference() -> float:
	return (global_transform.basis.z.dot(-_park_spot.global_transform.basis.z) + 1) / 2
	
func _get_normalized_velocity():
	var max_vel = acceleration / mass * 40
	return linear_velocity.normalized() * (linear_velocity.length() / max_vel)


func on_collide(body):
#	if body is VehicleBody3D:
	_end_episode(REWARD_COLLISION)
