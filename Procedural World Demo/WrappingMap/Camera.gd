extends Camera

var look_sensitivity: float = 100.0
var min_look_angle: float = -90.0
var max_look_angle: float = 90.0
var move_speed: float = 10.0
var enabled: bool = true
var mouse_delta: Vector2 = Vector2()
var rot: Vector3 = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if enabled and event is InputEventMouseMotion:
		mouse_delta = event.relative
	if event.is_action_pressed("ui_cancel"):
		if enabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		enabled = not enabled

func _process(delta):
	var rot_target = Vector3(mouse_delta.y, mouse_delta.x, 0)
	rot_target = rot_target.normalized() * look_sensitivity
	rot =  rot.linear_interpolate(rot_target, 0.5)
	rotation_degrees.x -= rot.x * delta #rot.x
	rotation_degrees.x = clamp(rotation_degrees.x, min_look_angle, max_look_angle)
	rotation_degrees.y -= rot.y * delta #rot.y
	mouse_delta = Vector2()
	
	var input = Vector3()
	input.z -= Input.get_action_strength("move_forward")
	input.z += Input.get_action_strength("move_backward")
	input.x -= Input.get_action_strength("move_left")
	input.x += Input.get_action_strength("move_right")
	input.y += Input.get_action_strength("jump")
	input.y -= Input.get_action_strength("crouch")
	if input.length_squared() > 1.0:
		input = input.normalized()
	
	var dir = (transform.basis.x * input.x + Vector3.UP * input.y + transform.basis.z * input.z)
	
	transform.origin += dir * move_speed * delta
