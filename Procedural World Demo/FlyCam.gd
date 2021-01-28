extends Spatial


onready var camera = get_node("Camera")
var mouse_delta: Vector2
var enabled: bool
var look_sensitivity: float = 0.25
var move_speed: float = 50.0
var cam_motion: Vector2

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
	camera.rotate_x(-look_dir.y * delta)
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
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
	
	var dir = (transform.basis.x * input.x + Vector3.UP * input.y + transform.basis.z * input.z)
	
	transform.origin += dir * move_speed * delta
