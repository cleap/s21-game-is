extends Spatial

onready var upper_leg = get_node("UpperLeg")
onready var mid_leg = get_node("MidLeg")
onready var lower_leg = get_node("LowerLeg")
onready var target_point = get_node("Tip")
onready var next_target_point = get_node("NextTarget")

onready var upper = get_node("UpperSeg")
onready var mid = get_node("MidSeg")
onready var lower = get_node("LowerSeg")

var segments: Array

const SEG_LEN = 1

var step_distance = pow(1.5, 2)
var step_height = 0.5
var step_speed = 6.0
var tip: Vector3

var target: Vector3
var origin: Vector3
var amt: float

var _segments: Array

func _ready():
	target = target_point.global_transform.origin
	tip = target 
	_segments = [
		upper_leg,
		mid_leg,
		lower_leg
	]
	segments = [ 
		upper,
		mid,
		lower
	]

func _physics_process(delta):
	update(next_target_point.global_transform.origin, delta)

func update(next_target: Vector3, delta: float):
	# Solve ik
	var new_target = global_transform.xform_inv(get_target(next_target, delta))
	solve_ik(new_target)

func get_target(next_target: Vector3, delta: float):
	if (next_target - target).length_squared() >= step_distance:
		target = next_target
		origin = tip
		amt = 0.0
	
	target_point.global_transform.origin = target
	if amt > 1.0:
		return target
	amt += step_speed * delta
	var x1 = 0
	var y1 = 0
	
	var x2 = 0.5
	var y2 = step_height
	
	var x3 = 1
	var y3 = 0
	
	var res = lerp(origin, target, sqrt(amt))
	
	# Lagrange polynomial
	var l2 = y2 * ((amt - x1)*(amt - x3)) / ((x2 - x1)*(x2 - x3))
	res.y += l2
	
	return res

func solve_ik(target: Vector3):
	var diff = target
	diff.y = 0
	diff = diff.normalized()
	var angle_y = acos(diff.z)
	if diff.x < 0.0:
		angle_y = -angle_y

#	segments[0].transform.origin = Vector3.ZERO
#	segments[0].rotation.y = angle_y
#	segments[1].transform.origin = segments[0].get_tip()
#	segments[1].transform.origin = segments[1].get_tip()
#	segments[2].transform.origin = segments[1].get_tip()
	for segment in segments:
		segment.rotation.y = angle_y

	segments[len(_segments) - 1].place_tip(target)
	for j in range(1, len(_segments) - 1):
		var i = len(_segments) - j - 1
		segments[i].solve_ik(segments[i + 1].transform.origin, segments[i - 1].rotation)
	segments[0].solve_ik(segments[1].transform.origin, Vector3.ZERO)
	
	segments[0].transform.origin = Vector3.ZERO
	for i in range(1, len(_segments)):
		segments[i].place_base(segments[i - 1].get_tip())
	
	tip = global_transform.xform(segments[-1].get_tip())
#	ik_helper(target, len(_segments) - 1, angle_y)
#	for j in range(1, len(_segments)):
#		var i = len(_segments) - j - 1
#		ik_helper(_segments[i + 1].transform.origin, i, angle_y)
#
#	_segments[0].transform.origin = Vector3.ZERO
#	for i in range(1, len(_segments)):
#		fk_helper(i, angle_y)
#	update_tip(angle_y)

func ik_helper(target: Vector3, index: int, angle_y: float):
	_segments[index].rotation.y = angle_y
	var diff = target - _segments[index].transform.origin
	diff = Vector3(
		0.0,
		diff.y,
		diff.z/cos(angle_y)
	)
	diff = diff.normalized()
	var angle = -acos(diff.z)
	if diff.y < 0.0:
		angle = -angle
	_segments[index].rotation.x = angle
	_segments[index].rotation.y = angle_y
	_segments[index].transform.origin = target
	_segments[index].transform.origin.x -= SEG_LEN * \
		cos(-_segments[index].rotation.x) * sin(angle_y)
	_segments[index].transform.origin.z -= SEG_LEN * \
		cos(-_segments[index].rotation.x) * cos(angle_y)
	_segments[index].transform.origin.y -= SEG_LEN * \
		sin(-_segments[index].rotation.x)

func fk_helper(index: int, angle_y: float):
	_segments[index].transform.origin = _segments[index - 1].transform.origin
	_segments[index].transform.origin.x += SEG_LEN * \
		cos(-_segments[index-1].rotation.x) * sin(angle_y)
	_segments[index].transform.origin.z += SEG_LEN *  \
		cos(-_segments[index-1].rotation.x) * cos(angle_y)
	_segments[index].transform.origin.y += SEG_LEN *  \
		sin(-_segments[index-1].rotation.x)
	_segments[index].rotation.y = angle_y

func update_tip(angle_y: float):
	var i = len(_segments) - 1
	tip = _segments[i].transform.origin
	tip.x += SEG_LEN * cos(-_segments[i].rotation.x) * sin(angle_y)
	tip.z += SEG_LEN * cos(-_segments[i].rotation.x) * cos(angle_y)
	tip.y += SEG_LEN * sin(-_segments[i].rotation.x)
	tip = global_transform.xform(tip)
