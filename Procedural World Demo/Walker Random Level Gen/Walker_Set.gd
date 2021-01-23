extends Node
class_name Walker

const DIRECTIONS = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

var position = Vector2.ZERO
var direction = Vector2.RIGHT
var borders = Rect2()
var step_history = []
var step_since_turn = 0
var rooms = []

func _init(starting_position, new_borders):
	assert(new_borders.has_point(starting_position))
	position = starting_position
	step_history.append(position)
	borders = new_borders

func walk(steps):
	place_room(position)
	for step in steps:
		#if randf() <= 0.25 and step_since_turn >= 6:
		# ^ this is more random
		if step_since_turn >= 6:
		# ^ this looks more uniform
			change_direction()
		
		if step():
			step_history.append(position)
		else:
			change_direction()
	return step_history

func step():
	var target_position = position + direction
	if borders.has_point(target_position):
		step_since_turn += 1
		position = target_position
		return true
	else:
		return false

func change_direction():
	place_room(position)
	step_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	direction = directions.pop_front()
	while not borders.has_point(position + direction):
		direction = directions.pop_front()

func create_room(_position, size):
	return {position = _position, size = size}

func place_room(_position):
	var size = Vector2(randi() % 4 + 2, randi() % 4 + 2)
	var top_left_corner = (_position - size/2).ceil()
	rooms.append(create_room(_position, size))
	for y in size.y:
		for x in size.x:
			var new_step = top_left_corner + Vector2(x, y)
			if borders.has_point(_position):
				step_history.append(new_step)

func get_end_room():
	var end_room = rooms.pop_front()
	var starting_position = step_history.pop_front()
	for room in rooms:
		if starting_position.distance_to(room.position) > starting_position.distance_to(end_room.position):
			end_room = room
	return end_room
