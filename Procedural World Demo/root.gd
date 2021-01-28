extends Spatial

const NUM_VILLAGES = 10

onready var mesh = get_node("MeshInstance")
var terrain: Terrain

# Called when the node enters the scene tree for the first time.
func _ready():
	terrain = Terrain.new()
	var village = Village.new()
	var reqs = []
	
	terrain.generate(mesh)
	
	for i in NUM_VILLAGES:
		var vreq = VillageReq.new(510.0,10,"normal")
		reqs.append(vreq)
	
	var plots = terrain.get_locations(reqs)
	var placements = village.gen_villages(plots)
	terrain.place_villages(placements)

func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_focus_next"):
			terrain.generate(mesh)
