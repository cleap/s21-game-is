extends Spatial

const NUM_VILLAGES = 3
const Terrain_Scene = preload("res://Terrain.tscn")
var terrain: Terrain

# Called when the node enters the scene tree for the first time.

func _ready():
	call_deferred("generate")

func generate():
	terrain = Terrain_Scene.instance()
	var reqs = []
	
#	get_tree().get_root().call_deferred("add_child", terrain)
	get_tree().get_root().add_child(terrain)
	
	for i in NUM_VILLAGES:
		var vreq = VillageReq.new(510.0,10,"normal")
		reqs.append(vreq)
	var plots = terrain.get_locations(reqs)
	place_villages(plots)
	

func place_villages(plots: Array):
#	get_tree().get_root().add_child(terrain)
	for plot in plots:
		var placement = Village.gen_village(plot)
#		get_tree().get_root().add_child(placement)
#		placement.transform.origin = plot.origin
		terrain.place_village(placement, plot)

#func _input(event):
#	if event is InputEventKey:
#		if Input.is_action_just_pressed("ui_focus_next"):
#			terrain.generate(mesh)

