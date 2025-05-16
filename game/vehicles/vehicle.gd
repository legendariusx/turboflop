extends VehicleBody3D
class_name Vehicle

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.4
const BRAKE_STRENGTH = 2.0
const BRAKE_SOFT_STRENGTH = 0.5

var _is_steering : bool
var _is_accelerating : bool
var _is_braking : bool

var _speed : float

@export var acceleration_force := 40.0

func _physics_process(delta: float) -> void:
	# get input
	var steer_axis = Input.get_axis(&"turn_right", &"turn_left")
	var force_axis = Input.get_axis(&"reverse", &"accelerate")
	var brake_strength = Input.get_action_strength(&"brake")
	
	# set input flags
	_is_steering = not is_zero_approx(steer_axis)
	_is_accelerating = not is_zero_approx(force_axis)
	_is_braking = Input.is_action_pressed(&"brake")
	
	# get current speed
	_speed = linear_velocity.dot(transform.basis.z)
	
	# set steering angle
	steering = move_toward(steering, steer_axis * STEER_LIMIT, delta * STEER_SPEED)
	
	# set brake
	if _is_braking:
		brake = brake_strength * BRAKE_STRENGTH
	# TODO: is this needed? currently stops the car
	elif not _is_accelerating and false:
		brake = BRAKE_SOFT_STRENGTH
	else:
		brake = 0.0
	
	# set engine force
	if _is_accelerating and not _is_braking:
		var force = force_axis * acceleration_force
		if abs(_speed) < 5.0 and not is_zero_approx(_speed):
			engine_force = clampf(force * 5.0 / abs(_speed), -100.0, 100.0)
		else:
			engine_force = force
	else:
		engine_force = 0.0
	
