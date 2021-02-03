extends Spatial
class_name Cave
#const testPlayer = preload("res://Walker Random Level Gen/testPlayer.tscn")
#const exitDoor = preload("res://Walker Random Level Gen/exitDoor.tscn")

#const WIDTH = 30
#const HEIGHT = 17
#
#var borders = Rect2(1, 1, WIDTH, HEIGHT)
var boxes: Array = []

func _ready():
	randomize()
	generate_level("normal")

func rect_collide(r1, r2):
	var x1 = r1.position.x
	var y1 = r1.position.y
	var width1 = r1.size.x
	var height1 = r1.size.y
	var x2 = r2.position.x
	var y2 = r2.position.y
	var width2 = r2.size.x
	var height2 = r2.size.y
	
	return (x1 < x2 + width2 + 2.5 and 
	x1 + width1 + 2.5 > x2 and 
	y1 < y2 + height2 + 2.5 and 
	y1 + height1 + 2.5 > y2)

func generate_level(size: String):
	var these_steps = 0
	var width = 0.0
	var height = 0.0
	
	if size == "small":
		these_steps = 250
		width = 17
		height = 17
	elif size == "normal":
		these_steps = 500
		width = 30
		height = 17
	elif size == "large":
		these_steps = 10000
		width = 60
		height = 60
	else:
		print("ERROR: I don't recognize that level size")
		return
	var borders = Rect2(1, 1, width, height)
	var walker = Walker3D.new(Vector2(width/2, height/2), borders)
	var map = walker.walk(these_steps)
	
#	var player = testPlayer.instance()
#	add_child(player)
#	player.position = map.front()*32
#
#	var exit = exitDoor.instance()
#	add_child(exit)
#	exit.position = walker.get_end_room().position*32
#	exit.connect("leaving_level", self, "reload_level")
#	print(walker.rooms)
	
	var placed_rooms = []
	for room in walker.rooms:
		
		var does_collide = false
		for placed_room in placed_rooms:
			if rect_collide(room, placed_room):
				does_collide = true
				break
		
		if not does_collide:
			placed_rooms.append(room)
			var mat: SpatialMaterial = SpatialMaterial.new()
			mat.flags_unshaded = true
			mat.albedo_color = Color.aliceblue
			var box: MeshInstance = MeshInstance.new()
			
			box.transform.origin = Vector3(room.position.x, 0.0, room.position.y)
			box.scale = Vector3(room.size.x/2.0, 1.0, room.size.y/2.0)
			box.set_surface_material(0, mat)
			box.set_mesh(CubeMesh.new())
			box.set_surface_material(0, mat)
			boxes.append(box)
			
			var col = CollisionShape.new()
			col.set_shape(BoxShape.new())
			box.add_child(col)
			
			add_child(box)
	
#	for location in map:
#		var rooms = walker.rooms
#		var mat: SpatialMaterial = SpatialMaterial.new()
#		mat.flags_unshaded = true
#		var box: MeshInstance = MeshInstance.new()
#		box.set_mesh(CubeMesh.new())
#		box.transform.origin = Vector3(location.x - WIDTH/2.0, 0.0, location.y - HEIGHT/2.0) * 2.0
#		box.set_surface_material(0, mat)
#		boxes.append(box)
#		add_child(box)
		
	walker.queue_free()
	
#		get_tree().get_root().call_deferred("add_child", box)

func reload_level():
	for box in boxes:
		box.queue_free()
	boxes = []
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		reload_level()
