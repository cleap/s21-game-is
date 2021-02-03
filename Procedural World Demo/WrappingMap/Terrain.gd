extends Spatial
class_name Terrain

const Chunk_Scene = preload("res://WrappingMap/TerrainChunk.tscn")
var chunks: Array # An array of the lods different chunks are loaded at

export var noise : OpenSimplexNoise = OpenSimplexNoise.new()

const CHUNK_WIDTH = 64
const MAP_WIDTH = 5 #16 # Chunks
const TILE_WIDTH = 16.0
const LODS = [0, 32, 64, 128]
const RENDER_DISTANCE = CHUNK_WIDTH
const RENDER_DISTANCE2 = RENDER_DISTANCE*RENDER_DISTANCE

func _ready():
	noise.period = 1000.0
	randomize()
	noise.seed = randi()
	chunks = []
	for i in MAP_WIDTH:
		var temp = []
		for j in MAP_WIDTH:
			var chunk: TerrainChunk = Chunk_Scene.instance()
			temp.append(chunk)
			add_child(chunk)
			chunk.generate(noise, i*CHUNK_WIDTH, j*CHUNK_WIDTH, CHUNK_WIDTH, MAP_WIDTH, 64)
		chunks.append(temp)

func dist2(p1: Vector2, p2: Vector2):
	return pow(p1.x - p2.x, 2.0) + pow(p1.y - p2.y, 2.0)

func load_chunk(i: int, j: int, lod: int):
	var i2 = ((i+MAP_WIDTH)%MAP_WIDTH)%MAP_WIDTH
	var j2 = ((j+MAP_WIDTH)%MAP_WIDTH)%MAP_WIDTH
	var prev = chunks[i2][j2].get_current_lod()
	if lod == 0:
		chunks[i2][j2].unload()
	elif lod != prev:
		print("(%d, %d): Previous lod: %d | New lod: %d" % [i, j, prev, lod])
		chunks[i2][j2].generate(noise, i*CHUNK_WIDTH, j*CHUNK_WIDTH, CHUNK_WIDTH, MAP_WIDTH, 64)

func update_chunks(player: Vector3):
	for i in MAP_WIDTH:
		for j in MAP_WIDTH:
			var play = Vector2(player.x, player.z)
			var p1 = Vector2( i   *CHUNK_WIDTH,  j   *CHUNK_WIDTH)
			var p2 = Vector2((i+1)*CHUNK_WIDTH,  j   *CHUNK_WIDTH)
			var p3 = Vector2((i+1)*CHUNK_WIDTH, (j+1)*CHUNK_WIDTH)
			var p4 = Vector2( i   *CHUNK_WIDTH, (j+1)*CHUNK_WIDTH)
			var dist = dist2(play, p1)
			dist = min(dist, dist2(play, p2))
			dist = min(dist, dist2(play, p3))
			dist = min(dist, dist2(play, p4))
			if dist <= RENDER_DISTANCE2:
				load_chunk(i, j, 64)
			else:
				load_chunk(i, j, 0)

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
