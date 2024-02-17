extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var initial_pos = transform.origin
@onready var ai_controller_3d = $AIController3D

func _physics_process(delta) -> void:
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)

	velocity.x = ai_controller_3d.move.x
	velocity.z = ai_controller_3d.move.y
	move_and_slide()

func _reset() -> void:
	transform.origin = initial_pos


func _on_reach_target(body):
	ai_controller_3d.reward += 1.0
	_reset()


func _on_out_of_bounds(body):
	ai_controller_3d.reward -= 1.0
	ai_controller_3d.reset()
	_reset()
