extends Node2D

var borders = Rect2(3, 3, 28, 15)

onready var tileMap = $TileMap

func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker.new(Vector2(14, 7), borders)
	var map = walker.walk(100)
	walker.queue_free()
	for location in map:
		tileMap.set_cellv(location, -1)
	tileMap.update_bitmask_region(borders.position, borders.end)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
