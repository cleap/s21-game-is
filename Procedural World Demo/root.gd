extends Spatial

const NUM_VILLAGES = 10
const Terrain_Scene = preload("res://WrappingMap/Terrain.tscn")

onready var player = get_node("Player")
var terrain

# Called when the node enters the scene tree for the first time.

func _ready():
#	call_deferred("generate")
	generate()

func generate():
	terrain = Terrain_Scene.instance()
	var reqs = []
	var v_size = ["small", "normal", "large"]
	
	
	call_deferred("add_child", terrain)
#	get_tree().get_root().add_child(terrain)
	
	for i in NUM_VILLAGES:
		var size = v_size[randi() % v_size.size()]
		var vreq = VillageReq.new(510.0,10,size)
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

#func _process(delta):
#	terrain.update_chunks(player.transform.origin)

#func _input(event):
#	if event is InputEventKey:
#		if Input.is_action_just_pressed("ui_focus_next"):
#			terrain.generate()

