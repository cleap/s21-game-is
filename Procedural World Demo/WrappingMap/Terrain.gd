extends Spatial
class_name Terrain

const Chunk_Scene = preload("res://WrappingMap/TerrainChunk.tscn")
var chunks: Array # An array of the lods different chunks are loaded at

export var terrain_noise : OpenSimplexNoise = OpenSimplexNoise.new()
export var moisture_noise : OpenSimplexNoise = OpenSimplexNoise.new()
export var heat_noise : OpenSimplexNoise = OpenSimplexNoise.new()

const CHUNK_WIDTH = 256
const NUM_CHUNKS = 16
const MAP_WIDTH = 256
const LODS = [0, 32, 64, 128]
const RENDER_DISTANCE = CHUNK_WIDTH
const RENDER_DISTANCE2 = RENDER_DISTANCE*RENDER_DISTANCE

func _ready():
	terrain_noise.period = 25000.0
	moisture_noise.period = 25000.0
	heat_noise.period = 25000.0
	randomize()
	terrain_noise.seed = randi()
	moisture_noise.seed = randi()
	heat_noise.seed = randi()
	generate()

func dist2(p1: Vector2, p2: Vector2):
	return pow(p1.x - p2.x, 2.0) + pow(p1.y - p2.y, 2.0)

# TODO
func load_chunk(i: int, j: int, lod: int):
	var i2 = ((i+NUM_CHUNKS)%NUM_CHUNKS)%NUM_CHUNKS
	var j2 = ((j+NUM_CHUNKS)%NUM_CHUNKS)%NUM_CHUNKS
	var prev = chunks[i2][j2].get_current_lod()
	if lod == 0:
		chunks[i2][j2].unload()
	elif lod != prev:
#		print("(%d, %d): Previous lod: %d | New lod: %d" % [i, j, prev, lod])
		chunks[i2][j2].generate(terrain_noise, i*CHUNK_WIDTH, j*CHUNK_WIDTH, CHUNK_WIDTH, NUM_CHUNKS, 256)

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
		placement.scale = Vector3(10.0, 20.0, 10.0)
		print("Plot origin: %s" % plot.origin)
		print("Placement origin %s" % placement.transform.origin)
		print("---")

var terrain_texture: ImageTexture
var heat_texture: ImageTexture
var moisture_texture: ImageTexture
var tiles: Array

func generate():
	var min_height = INF
	var max_height = -INF
	var min_heat = INF
	var max_heat = -INF
	var min_moist = INF
	var max_moist = -INF
	var heights = []
	var heats = []
	var moists = []

	for i in MAP_WIDTH:
		var heights2 = []
		var heats2 = []
		var moists2 = []
		var x = i * CHUNK_WIDTH * NUM_CHUNKS / float(MAP_WIDTH)
		for j in MAP_WIDTH:
			var y = j * CHUNK_WIDTH * NUM_CHUNKS / float(MAP_WIDTH)
			var height = get_noise_val(terrain_noise, x, y)
			if height < min_height:
				min_height = height
			if height > max_height:
				max_height = height
			heights2.append(height)
			
			var heat_mult = get_noise_val(heat_noise, x, y)
			if heat_mult < min_heat:
				min_heat = heat_mult
			if heat_mult > max_heat:
				max_heat = heat_mult
			heats2.append(heat_mult)
			
			var moist = get_noise_val(moisture_noise, x, y)
			if moist < min_moist:
				min_moist = moist
			if moist > max_moist:
				max_moist = moist
			moists2.append(moist)
		heights.append(heights2)
		heats.append(heats2)
		moists.append(moists2)
	
	tiles = []
	for i in MAP_WIDTH:
		var x = i * CHUNK_WIDTH * NUM_CHUNKS / float(MAP_WIDTH)
		var temp = []
		for j in MAP_WIDTH:
			var y = j * CHUNK_WIDTH * NUM_CHUNKS / float(MAP_WIDTH)
			var height = (heights[i][j] - min_height) / (max_height - min_height)
			
			var heat_val = 1.0 - abs(j - MAP_WIDTH/2.0)*2.0/float(MAP_WIDTH)
			var heat_mult = (heats[i][j] - min_heat) / (max_heat - min_heat)
			heat_mult = heat_mult*0.25 + 0.75
			heat_val *= heat_mult #TODO: Incorporate heat multiplier
			
			var moist_val = (moists[i][j] - min_moist) / (max_moist - min_moist)

			temp.append(Tile.new(i, j, height, heat_val, moist_val))
		tiles.append(temp)
	
	for i in MAP_WIDTH:
		for j in MAP_WIDTH:
			var up = 	tiles[i][(j + 1) % MAP_WIDTH]
			var down = 	tiles[i][(j - 1 + MAP_WIDTH) % MAP_WIDTH]
			var left = 	tiles[(i - 1 + MAP_WIDTH) % MAP_WIDTH][j]
			var right =	tiles[(i + 1 ) % MAP_WIDTH][j]
			tiles[i][j].set_neighbors(up, down, left, right)
	for i in MAP_WIDTH:
		for j in MAP_WIDTH:
			tiles[i][j].update_color()
	update_textures()
	
#	# TODO: put this in update_chunks
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
			chunk.generate(terrain_noise, i*CHUNK_WIDTH, j*CHUNK_WIDTH, CHUNK_WIDTH, NUM_CHUNKS, 16, min_height, max_height)
		chunks.append(temp)

func update_textures():
	terrain_texture = ImageTexture.new()
	heat_texture = ImageTexture.new()
	moisture_texture = ImageTexture.new()
	var terrain_image = Image.new()
	var heat_image = Image.new()
	var moisture_image = Image.new()
	
	terrain_image.create(MAP_WIDTH, MAP_WIDTH, false, Image.FORMAT_RGB8)
	heat_image.create(MAP_WIDTH, MAP_WIDTH, false, Image.FORMAT_RGB8)
	moisture_image.create(MAP_WIDTH, MAP_WIDTH, false, Image.FORMAT_RGB8)
	terrain_image.lock()
	heat_image.lock()
	moisture_image.lock()
	for i in MAP_WIDTH:
		for j in MAP_WIDTH:
			terrain_image.set_pixel(i, j, tiles[i][j].get_terrain_color())
			heat_image.set_pixel(i, j, tiles[i][j].get_heat_color())
			moisture_image.set_pixel(i, j, tiles[i][j].get_moisture_color())
	terrain_image.unlock()
	heat_image.unlock()
	moisture_image.unlock()
	
	terrain_texture.create_from_image(terrain_image)
	heat_texture.create_from_image(heat_image)
	moisture_texture.create_from_image(moisture_image)

func get_noise_val(noise: OpenSimplexNoise, x: float, y: float):
	var map_width = CHUNK_WIDTH * NUM_CHUNKS
	var rad = 2.0*PI*map_width
	var theta = 2.0*PI*x/map_width
	var phi = 2.0*PI*y/map_width
	var val = noise.get_noise_4d(rad*cos(theta), rad*sin(theta), rad*cos(phi), rad*sin(phi))
	return val

