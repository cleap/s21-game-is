extends KinematicBody

class_name Entity

var legs

export var move_speed = 2.0
export var target_speed = 0.5
var ray_offset = Vector3(0.0, 0.0, 1.746)
var inited = false

var vel = Vector3.ZERO

func _physics_process(delta):
	var dir = Vector3.ZERO
	dir.z -= Input.get_action_strength("ui_down")
	dir.z += Input.get_action_strength("ui_up")
	dir.x += Input.get_action_strength("ui_left")
	dir.x -= Input.get_action_strength("ui_right")
	vel = lerp(vel, dir, 0.2)
	transform.origin += vel * delta * move_speed
	
	var floorcount = 0
	for leg in legs:
		if leg[0].is_grounded():
			floorcount += 1
	if not inited and floorcount == len(legs):
		inited = true
	
	for leg in legs:
	
		leg[1].transform.origin = leg[3]
		leg[1].global_transform.origin += global_transform.basis.x * vel.x * target_speed
		leg[1].global_transform.origin += global_transform.basis.z * vel.z * target_speed
		
		var before = leg[0].is_grounded()
		var target = leg[0].target
		
		if leg[1].is_colliding():
			leg[2].global_transform.origin = leg[1].get_collision_point()
		if not inited:
			leg[0].set_target(leg[2].global_transform.origin)
			leg[0].update(leg[2].global_transform.origin, delta)
		elif floorcount > len(legs) / 2:
			leg[0].update(leg[2].global_transform.origin, delta)
		else:
			leg[0].update(leg[0].target, delta)
		
		if target != leg[0].target:
			floorcount -= 1
		elif leg[0].is_grounded():
			floorcount += 1
