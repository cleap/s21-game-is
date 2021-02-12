extends Spatial
class_name TerrainChunk

var TILE_WIDTH
var TILES_PER_CHUNK
var MAP_WIDTH
var CHUNK_WIDTH

onready var mesh: MeshInstance = get_node("MeshInstance")
onready var col: CollisionShape = get_node("StaticBody/CollisionShape")

var min_val : float
var max_val : float
var noise: OpenSimplexNoise
var i0: int
var j0: int
var tiles: Array

var mutex = Mutex.new()

var current_lod: int

func get_current_lod():
	mutex.lock()
	var val = current_lod
	mutex.unlock()
	return val

func _ready():
	mutex.lock()
#	visible = false
	current_lod = 0
	mutex.unlock()

func init(tile_width, tiles_per_chunk, map_width, noise, i0, j0, tiles, min_val, max_val):
	TILE_WIDTH = tile_width
	TILES_PER_CHUNK = tiles_per_chunk
	MAP_WIDTH = map_width*TILE_WIDTH
	CHUNK_WIDTH = TILE_WIDTH * TILES_PER_CHUNK
	self.noise = noise
	self.i0 = i0
	self.j0 = j0
	self.tiles = tiles
	self.min_val = min_val
	self.max_val = max_val
	

func unload():
	mutex.lock()
	visible = false
	current_lod = 0
	mutex.unlock()

# From https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html
func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var q2 = p2.linear_interpolate(p3, t)

	var r0 = q0.linear_interpolate(q1, t)
	var r1 = q1.linear_interpolate(q2, t)

	var s = r0.linear_interpolate(r1, t)
	return s

func get_height(val : float, tile: Tile):
	
	var ground_mult = 100.0
	var mountain_mult = 1000.0
	
	if val <= Tile.SHALLOW_WATER:
		return 0
	elif val <= Tile.FOREST:
		return ground_mult * (val - Tile.SHALLOW_WATER)
	else:
		return mountain_mult * (val - Tile.FOREST) + ground_mult * (Tile.FOREST - Tile.SHALLOW_WATER)
#	else:
#	return _cubic_bezier(BASE, BEACH_TOP, GRASS_TOP, MOUNTAIN_TOP, val).y
#	return 100.0*val

func get_noise_val(x: float, y: float):
	var rad = 2.0*PI*MAP_WIDTH
	var theta = 2.0*PI*x/MAP_WIDTH
	var phi = 2.0*PI*y/MAP_WIDTH
	var val = noise.get_noise_4d(rad*cos(theta), rad*sin(theta), rad*cos(phi), rad*sin(phi))
	return val

func generate(lod: int):
	
	if lod == 0:
		unload()
		return
	elif lod == current_lod:
		visible = true
		return
	visible = true
	mutex.lock()
	current_lod = lod
#	print("(%f, %f): New lod: %d"%[i0, j0, lod])
	
	generate_mesh(lod)
	mutex.unlock()

func get_square(noise: OpenSimplexNoise, x, y, delta, min_val, max_val, tile):
	var pts = []
	var colors = []
	for i in range(2):
		var new_x = x + i*delta
		for j in range(2):
			var new_z = y + j*delta
			var val = get_noise_val(new_x, new_z)
			val = (val - min_val) / (max_val - min_val)
#			val = val * 0.5 + 0.5
			colors.push_front(tile.get_terrain_color())
			var origin = Vector3(new_x, get_height(val, tile), new_z)
			pts.push_front(origin)
	return [pts, colors]

# generate(noise, starti, startj, tiles, lod)
func generate_mesh(lod: int):
	var st: SurfaceTool = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var delta = TILE_WIDTH / float(lod)
	for i in range(i0, i0 + TILES_PER_CHUNK):
		for j in range(j0, j0 + TILES_PER_CHUNK):
			for x in lod:
				for y in lod:
					var xval = i*TILE_WIDTH + x*delta
					var yval = j*TILE_WIDTH + y*delta
					var tmp = get_square(noise, xval, yval, delta, min_val, max_val, tiles[i][j])
					var square = tmp[0]
					var colors = tmp[1]
					
					st.add_color(colors[0])
					st.add_vertex(square[0])
					st.add_color(colors[2])
					st.add_vertex(square[2])
					st.add_color(colors[1])
					st.add_vertex(square[1])
					
					st.add_color(colors[1])
					st.add_vertex(square[1])
					st.add_color(colors[2])
					st.add_vertex(square[2])
					st.add_color(colors[3])
					st.add_vertex(square[3])
			
	
	st.generate_normals()
	var triangles = st.commit()
	mesh.set_mesh(triangles)
#	mesh.set_surface_material(0, load("res://WrappingMap/map_shader.tres"))
	
	var col_shape: ConcavePolygonShape = ConcavePolygonShape.new()
	col_shape.set_faces(triangles.get_faces())
	col.set_shape(col_shape)
