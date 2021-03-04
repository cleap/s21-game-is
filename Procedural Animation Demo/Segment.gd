extends Spatial

export var length: float = 1.0
export var min_angle: float = 0.0
export var max_angle: float = PI/2.0

func get_tip():
	var tip = transform.origin
	tip.x += length * cos(-rotation.x) * sin(rotation.y)
	tip.z += length * cos(-rotation.x) * cos(rotation.y)
	tip.y += length * sin(-rotation.x)
	return tip

func place_tip(target: Vector3):
	transform.origin = target
	transform.origin.x -= length * cos(-rotation.x) * sin(rotation.y)
	transform.origin.z -= length * cos(-rotation.x) * cos(rotation.y)
	transform.origin.y -= length * sin(-rotation.x)

func place_base(target: Vector3):
	transform.origin = target

func angle_clamp(value: float, minimum: float, maximum):
	var v_min = fmod(abs(value - minimum), 2.0*PI)
	var v_max = fmod(abs(value - maximum), 2.0*PI)
	var min_max = fmod(abs(maximum - minimum), 2.0*PI)
	
	if v_min < min_max and v_max < min_max:
		return value
	elif v_min < v_max:
		return minimum
	else:
		return maximum

func solve_ik(target: Vector3, parent_rotation: Vector3):
	var diff = target - transform.origin
	diff = Vector3(
		0.0,
		diff.y,
		diff.z/cos(rotation.y)
	)
	diff = diff.normalized()
	var angle = -acos(diff.z)
	if diff.y < 0.0:
		angle = -angle
	
#	angle = angle_clamp(angle - parent_rotation.x, min_angle, max_angle)
	
	rotation.x = angle # + parent_rotation.x
	place_tip(target)
