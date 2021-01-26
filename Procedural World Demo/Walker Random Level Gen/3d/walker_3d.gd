extends Spatial

#const testPlayer = preload("res://Walker Random Level Gen/testPlayer.tscn")
#const exitDoor = preload("res://Walker Random Level Gen/exitDoor.tscn")

const WIDTH = 30
const HEIGHT = 17

var borders = Rect2(1, 1, WIDTH, HEIGHT)
var boxes: Array = []

func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker3D.new(Vector2(WIDTH/2, HEIGHT/2), borders)
	var map = walker.walk(200)
	
#	var player = testPlayer.instance()
#	add_child(player)
#	player.position = map.front()*32
#
#	var exit = exitDoor.instance()
#	add_child(exit)
#	exit.position = walker.get_end_room().position*32
#	exit.connect("leaving_level", self, "reload_level")
	
	walker.queue_free()
	for location in map:
		var mat: SpatialMaterial = SpatialMaterial.new()
		mat.flags_unshaded = true
		var box: MeshInstance = MeshInstance.new()
		box.set_mesh(CubeMesh.new())
		box.transform.origin = Vector3(location.x - WIDTH/2.0, 0.0, location.y - HEIGHT/2.0) * 2.0
		box.set_surface_material(0, mat)
		boxes.append(box)
		get_tree().get_root().call_deferred("add_child", box)

func reload_level():
	for box in boxes:
		box.queue_free()
	boxes = []
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		reload_level()

