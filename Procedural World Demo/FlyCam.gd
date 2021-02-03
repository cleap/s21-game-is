extends KinematicBody


onready var camera = get_node("CameraOrbit/Camera")
onready var cam_orbit = get_node("CameraOrbit")
const camera_offset = Vector3(0.0, 0.0, 5.0)
var mouse_delta: Vector2
var enabled: bool
var look_sensitivity: float = 0.25
var cam_motion: Vector2
var is_flying: bool = true
var vel: Vector3 = Vector3.ZERO
var fly_speed: float = 50.0
var move_speed: float = 20.0
var jump_strength = 30.0
var gravity = -100.0

var double_tap_time = 0.25
var double_space_timer = 2.0*double_tap_time

# Called when the node enters the scene tree for the first time.
func _ready():
	enabled = false
	cam_motion = Vector2.ZERO

func _input(event):
	if event is InputEventKey and Input.is_action_just_pressed("ui_cancel"):
		if enabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		enabled = not enabled
	elif enabled and event is InputEventMouseMotion:
		mouse_delta = event.relative

	if not enabled and event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var look_dir: Vector2 = mouse_delta
#	if look_dir.length_squared() > 1.0:
#		look_dir = look_dir.normalized()
	look_dir *= look_sensitivity
	cam_motion = cam_motion.linear_interpolate(look_dir, 0.8)
	rotate_y(-look_dir.x * delta)
	cam_orbit.rotate_x(-look_dir.y * delta)
	cam_orbit.rotation_degrees.x = clamp(cam_orbit.rotation_degrees.x, -90, 90)
	mouse_delta = Vector2.ZERO
	
	var input = Vector3()
	input.z -= Input.get_action_strength("move_forward")
	input.z += Input.get_action_strength("move_backward")
	input.x -= Input.get_action_strength("move_left")
	input.x += Input.get_action_strength("move_right")
	if input.length_squared() > 1.0:
		input = input.normalized()
	input.y += Input.get_action_strength("move_jump")
	input.y -= Input.get_action_strength("move_crouch")
	
	double_space_timer += delta
	if Input.is_action_just_pressed("move_jump"):
		if double_space_timer <= double_tap_time:
			is_flying = not is_flying
		double_space_timer = 0.0
		if not is_flying:
			vel.y = jump_strength
	var target = Vector3.ZERO
	if not is_flying:
		target = camera_offset
	camera.transform.origin = lerp(camera.transform.origin, target, 0.2)
	
	var dir = (transform.basis.x * input.x + transform.basis.z * input.z)
	if is_flying:
		dir +=  Vector3.UP * input.y
		transform.origin += dir * fly_speed * delta
	else:
		vel.z = dir.z * move_speed #lerp(vel.z, dir.z * move_speed, 0.8)
		vel.x = dir.x * move_speed #lerp(vel.x, dir.x * move_speed, 0.8)
		vel.y += gravity * delta
		vel = move_and_slide(vel, Vector3.UP)
	
	
