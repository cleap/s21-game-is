extends Spatial

onready var upper_leg = get_node("UpperLeg")
onready var mid_leg = get_node("MidLeg")
onready var lower_leg = get_node("LowerLeg")
onready var target_point = get_node("Tip")
onready var next_target_point = get_node("NextTarget")

const SEG_LEN = 1

var step_distance = 1.0 * 1.0
var step_height = 0.5
var step_speed = 0.2
var tip: Vector3

var target: Vector3
var origin: Vector3
var amt: float

var segments: Array

func _ready():
	target = target_point.transform.origin
	tip = target 
	segments = [
		upper_leg,
		mid_leg,
		lower_leg
	]

func _physics_process(delta):
	update(next_target_point.transform.origin, delta)

func update(next_target: Vector3, delta: float):
	# Solve ik
	
	solve_ik(get_target(next_target, delta))

func get_target(next_target: Vector3, delta: float):
	if (next_target - target).length_squared() >= step_distance:
		target = next_target
		target_point.transform.origin = target
		
		var diff = (tip - target)
		origin = target + diff
		
		amt = 0.0
	if amt > 1.0:
		return target
	amt += 1.0 * delta
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

	ik_helper(target, len(segments) - 1, angle_y)
	for j in range(1, len(segments)):
		var i = len(segments) - j - 1
		ik_helper(segments[i + 1].transform.origin, i, angle_y)
	
	segments[0].transform.origin = Vector3.ZERO
	for i in range(1, len(segments)):
		fk_helper(i, angle_y)
	update_tip(angle_y)

func ik_helper(target: Vector3, index: int, angle_y: float):
	var diff = target - segments[index].transform.origin
	diff.x = 0
	diff = diff.normalized()
	var angle = -acos(diff.z)
	if diff.y < 0.0:
		angle = -angle
	segments[index].rotation.x = angle
	segments[index].rotation.y = angle_y
	segments[index].transform.origin = target
	segments[index].transform.origin.x -= SEG_LEN * \
		cos(-segments[index].rotation.x) * sin(angle_y)
	segments[index].transform.origin.z -= SEG_LEN * \
		cos(-segments[index].rotation.x) * cos(angle_y)
	segments[index].transform.origin.y -= SEG_LEN * \
		sin(-segments[index].rotation.x)

func fk_helper(index: int, angle_y: float):
	segments[index].transform.origin = segments[index - 1].transform.origin
	segments[index].transform.origin.x += SEG_LEN * \
		cos(-segments[index-1].rotation.x) * sin(angle_y)
	segments[index].transform.origin.z += SEG_LEN *  \
		cos(-segments[index-1].rotation.x) * cos(angle_y)
	segments[index].transform.origin.y += SEG_LEN *  \
		sin(-segments[index-1].rotation.x)
	segments[index].rotation.y = angle_y

func update_tip(angle_y: float):
	var i = len(segments) - 1
	tip = segments[i].transform.origin
	tip.x += SEG_LEN * cos(-segments[i].rotation.x) * sin(angle_y)
	tip.z += SEG_LEN * cos(-segments[i].rotation.x) * cos(angle_y)
	tip.y += SEG_LEN * sin(-segments[i].rotation.x)
