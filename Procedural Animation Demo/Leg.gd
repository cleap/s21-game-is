extends Spatial

onready var target_point = get_node("Tip")

onready var upper = get_node("UpperSeg")
onready var mid = get_node("MidSeg")
onready var lower = get_node("LowerSeg")
onready var ray = get_node("RayCast")

var segments: Array

const SEG_LEN = 1

var step_distance = pow(1.0, 2)
var step_height = 0.6
var step_speed = 5.0
var tip: Vector3
var tolerance = 0.01

var target: Vector3
var origin: Vector3
var amt: float

var is_grounded = true

func _ready():
	target = target_point.global_transform.origin
	tip = target 
	segments = [ 
		upper,
		mid,
		lower
	]

func update(next_target: Vector3, delta):
	# Solve ik
	var new_target = global_transform.xform_inv(get_target(next_target, delta))
	solve_ik(new_target)
	if (new_target - tip).length_squared() >= tolerance:
		solve_ik(new_target)

func set_target(next_target: Vector3):
	target = next_target
	tip = global_transform.xform(segments[-1].get_tip())
	origin = tip
	amt = 0.0

func get_target(next_target: Vector3, delta: float):
	if (next_target - target).length_squared() >= step_distance:
		set_target(next_target)
	
	target_point.global_transform.origin = target
	if amt > 1.0:
		return target
	amt += step_speed * delta
	var x1 = 0
	
	var x2 = 0.5
	var y2 = step_height
	
	var x3 = 1
	
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

	for segment in segments:
		segment.rotation.y = angle_y

	segments[len(segments) - 1].solve_ik(target, segments[-2].rotation)
	for j in range(1, len(segments) - 1):
		var i = len(segments) - j - 1
		segments[i].solve_ik(segments[i + 1].transform.origin, segments[i - 1].rotation)
	segments[0].solve_ik(segments[1].transform.origin, Vector3.ZERO)
	
	segments[0].transform.origin = Vector3.ZERO
	for i in range(1, len(segments)):
		segments[i].place_base(segments[i - 1].get_tip())
	
	tip = global_transform.xform(segments[-1].get_tip())

func _physics_process(delta):
	ray.global_transform.origin = tip + Vector3(0.0, 0.1, 0.0)
	is_grounded = ray.is_colliding() and (tip - target).length_squared() < 0.01

func is_grounded():
	return is_grounded
