extends Spatial
class_name Terrain

const Chunk_Scene = preload("res://WrappingMap/TerrainChunk.tscn")
var chunks: Array # An array of the lods different chunks are loaded at

export var noise : OpenSimplexNoise = OpenSimplexNoise.new()

const CHUNK_WIDTH = 64
const NUM_CHUNKS = 5
const MAP_WIDTH = 256
const LODS = [0, 32, 64, 128]
const RENDER_DISTANCE = CHUNK_WIDTH
const RENDER_DISTANCE2 = RENDER_DISTANCE*RENDER_DISTANCE

func _ready():
	noise.period = 1000.0
	randomize()
	noise.seed = randi()
	generate()

func dist2(p1: Vector2, p2: Vector2):
	return pow(p1.x - p2.x, 2.0) + pow(p1.y - p2.y, 2.0)

func load_chunk(i: int, j: int, lod: int):
	var i2 = ((i+NUM_CHUNKS)%NUM_CHUNKS)%NUM_CHUNKS
	var j2 = ((j+NUM_CHUNKS)%NUM_CHUNKS)%NUM_CHUNKS
	var prev = chunks[i2][j2].get_current_lod()
	if lod == 0:
		chunks[i2][j2].unload()
	elif lod != prev:
		print("(%d, %d): Previous lod: %d | New lod: %d" % [i, j, prev, lod])
		chunks[i2][j2].generate(noise, i*CHUNK_WIDTH, j*CHUNK_WIDTH, CHUNK_WIDTH, NUM_CHUNKS, 64)

func update_chunks(player: Vector3):
	for i in NUM_CHUNKS:
		for j in NUM_CHUNKS:
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
		origin.x = randf() * CHUNK_WIDTH * NUM_CHUNKS
		origin.z = randf() * CHUNK_WIDTH * NUM_CHUNKS
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

const DEEP_WATER = 0.2
const SHALLOW_WATER = 0.4
const SAND = 0.5
const GRASS = 0.65
const FOREST = 0.8
const ROCK = 0.95
const SNOW = 1.0

const DEEP_COLOR = Color(0, 0, 0.5, 1.0)
const SHALLOW_COLOR = Color(25/255.0, 25/255.0, 150/255.0, 1.0)
const SAND_COLOR = Color(240/255.0, 240/255.0, 64/255.0, 1.0)
const GRASS_COLOR = Color(50/255.0, 220/255.0, 20/255.0, 1.0)
const FOREST_COLOR = Color(16/255.0, 160/255.0, 0.0, 1.0)
const ROCK_COLOR = Color(0.5, 0.5, 0.5, 1)
const SNOW_COLOR = Color.white

var map_texture: ImageTexture

func generate():
	var min_val = INF
	var max_val = -INF
	
	var temp1 = []
	for i in MAP_WIDTH:
		var x = i * CHUNK_WIDTH * NUM_CHUNKS / float(MAP_WIDTH)
		var temp2 = []
		for j in MAP_WIDTH:
			var y = j * CHUNK_WIDTH * NUM_CHUNKS / float(MAP_WIDTH)
			var val = get_noise_val(noise, x, y, CHUNK_WIDTH * NUM_CHUNKS)
			if val < min_val:
				min_val = val
			if val > max_val:
				max_val = val
			temp2.append(val)
		temp1.append(temp2)
	
	for x in MAP_WIDTH:
		for y in MAP_WIDTH:
			var val = temp1[x][y]
			temp1[x][y] = (val - min_val) / (max_val - min_val)
	update_texture(temp1)
	
	if(chunks.size() > 0):
		for col in chunks:
			for item in col:
				item.queue_free()
	chunks = []
	for i in NUM_CHUNKS:
		var temp = []
		for j in NUM_CHUNKS:
			var chunk: TerrainChunk = Chunk_Scene.instance()
			temp.append(chunk)
			add_child(chunk)
			chunk.generate(noise, i*CHUNK_WIDTH, j*CHUNK_WIDTH, CHUNK_WIDTH, NUM_CHUNKS, 64, min_val, max_val)
		chunks.append(temp)

func update_texture(arr):
	map_texture = ImageTexture.new()
	var dynImage = Image.new()
	
	dynImage.create(MAP_WIDTH, MAP_WIDTH, false, Image.FORMAT_RGB8)
	dynImage.lock()
	for x in MAP_WIDTH:
		for y in MAP_WIDTH:
			var val = arr[x][y]
			dynImage.set_pixel(x, y, get_color(val))
	dynImage.unlock()
	
	map_texture.create_from_image(dynImage)

func get_noise_val(noise: OpenSimplexNoise, x: float, y: float, map_width: float):
	var rad = 2.0*PI*map_width
	var theta = 2.0*PI*x/map_width
	var phi = 2.0*PI*y/map_width
	var val = noise.get_noise_4d(rad*cos(theta), rad*sin(theta), rad*cos(phi), rad*sin(phi))
	return val

func get_color(val: float):
	var color: Color
	if val <= DEEP_WATER:
		color = DEEP_COLOR
	elif val <= SHALLOW_WATER:
		color = SHALLOW_COLOR
	elif val <= SAND:
		color = SAND_COLOR
	elif val <= GRASS:
		color = GRASS_COLOR
	elif val <= FOREST:
		color = FOREST_COLOR
	elif val <= ROCK:
		color = ROCK_COLOR
	else:
		color = SNOW_COLOR
	return color
