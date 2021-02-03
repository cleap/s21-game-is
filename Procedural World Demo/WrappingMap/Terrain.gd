extends Spatial
class_name Terrain

const Chunk_Scene = preload("res://WrappingMap/TerrainChunk.tscn")
var chunks: Array

export var noise : OpenSimplexNoise = OpenSimplexNoise.new()

const CHUNK_WIDTH = 64
const MAP_WIDTH = 5 #16 # Chunks
const TILE_WIDTH = 16.0

func _ready():
	noise.period = 1000.0
	randomize()
	noise.seed = randi()
	for i in MAP_WIDTH:
		for j in MAP_WIDTH:
			var chunk = Chunk_Scene.instance()
			add_child(chunk)
			chunk.generate(noise, i*CHUNK_WIDTH, j*CHUNK_WIDTH, CHUNK_WIDTH, MAP_WIDTH, 64)

func get_locations(reqs: Array):
	var arr = []
	for req in reqs:
		var width = sqrt(req.area)
		var origin: Vector3 = Vector3.ZERO
		origin.x = randf() * CHUNK_WIDTH * MAP_WIDTH
		origin.z = randf() * CHUNK_WIDTH * MAP_WIDTH
		origin.y = 10.0
		arr.append(VillagePlot.new(
			Rect2(Vector2.ZERO, Vector2(width, width)),
			req.num_houses, 
			req.type,
			origin))
	return arr

func place_village(placement: Spatial, plot: VillagePlot):
#		get_tree().get_root().call_deferred("add_child", placement)
		add_child(placement)
		placement.translate(plot.origin)
		print("Plot origin: %s" % plot.origin)
		print("Placement origin %s" % placement.transform.origin)
		print("---")
