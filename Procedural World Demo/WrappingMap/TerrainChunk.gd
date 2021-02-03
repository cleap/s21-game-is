extends Spatial
class_name TerrainChunk

const Tile = preload("res://WrappingMap/Tile.gd")
onready var mesh : MeshInstance = get_node("MeshInstance")

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

var min_val : float
var max_val : float

#func _ready():
#	noise = OpenSimplexNoise.new()
#	noise.period = 150.0
#	randomize()


# From https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html
func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var q2 = p2.linear_interpolate(p3, t)

	var r0 = q0.linear_interpolate(q1, t)
	var r1 = q1.linear_interpolate(q2, t)

	var s = r0.linear_interpolate(r1, t)
	return s

func get_height(val : float):
	
	var sand_mult = 20.0
	var grass_mult = 40.0
	
	var BASE = Vector2(SHALLOW_WATER, 0.0)
	var BEACH_TOP = Vector2(SAND, SAND*sand_mult)
	var GRASS_TOP = Vector2(FOREST, BEACH_TOP.y + FOREST*grass_mult)
	var MOUNTAIN_TOP = Vector2(SNOW, 100.0)
#	var curve = AnimationT
	if val <= SHALLOW_WATER:
		return 0.0
#	else:
#	return _cubic_bezier(BASE, BEACH_TOP, GRASS_TOP, MOUNTAIN_TOP, val).y
	elif val <= SAND:
		return (val - SHALLOW_WATER) * sand_mult
	elif val <= FOREST:
		return (val - SAND) * grass_mult + (SAND - SHALLOW_WATER) * sand_mult
	return (pow(10.0*val, (val - FOREST)) - 1.0) * 50.0 + (FOREST - SAND) * grass_mult + (SAND - SHALLOW_WATER) * sand_mult

func get_noise_val(noise: OpenSimplexNoise, x: float, y: float, map_width: float):
	var rad = 2.0*PI*map_width
	var theta = 2.0*PI*x/map_width
	var phi = 2.0*PI*y/map_width
	var val = noise.get_noise_4d(rad*cos(theta), rad*sin(theta), rad*cos(phi), rad*sin(phi))
	return val

func generate(noise: OpenSimplexNoise, x0: float, y0: float, chunk_width: int, num_chunks: int, lod: int):
	var tiles: Array = []
	min_val = INF
	max_val = -INF
	
	var temp1 = []
	for i in lod:
		var x = (x0 + i*chunk_width/float(lod))
		var temp2 = []
		for j in lod:
			var y = (y0 + j*chunk_width/float(lod))
			var val = get_noise_val(noise, x, y, chunk_width * num_chunks)
			if val < min_val:
				min_val = val
			if val > max_val:
				max_val = val
			temp2.append(val)
		temp1.append(temp2)
	
	for x in lod:
		var temp: Array = []
		for y in lod:
			var val = temp1[x][y]
			val = (val - min_val) / (max_val - min_val)
			temp.append(Tile.new(get_color(val)))
		tiles.append(temp)
	print(max_val)
	print(min_val)
	
#	texture.update(MAP_WIDTH, MAP_HEIGHT, tiles)
	generate_mesh(noise, x0, y0, chunk_width, num_chunks, lod)

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

func get_square(noise: OpenSimplexNoise, x, y, delta, map_width):
	var pts = []
	var colors = []
	for i in range(2):
		var new_x = x + i*delta
		for j in range(2):
			var new_z = y + j*delta
			var val = get_noise_val(noise, new_x, new_z, map_width)
#			val = (val - min_val) / (max_val - min_val)
			val = val * 0.5 + 0.5
			colors.push_front(get_color(val))
			var origin = Vector3(new_x, get_height(val), new_z)
			pts.push_front(origin)
	return [pts, colors]

func generate_mesh(noise: OpenSimplexNoise, x0: float, y0: float, chunk_width: float, num_chunks: int, lod: int):
	var st: SurfaceTool = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in lod:
		var x = (x0 + i*chunk_width/float(lod))
		for j in lod:
			var y = (y0 + j*chunk_width/float(lod))
			var tmp = get_square(noise, x, y, chunk_width/float(lod), chunk_width*num_chunks)
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
	
#	var col_shape: ConcavePolygonShape = ConcavePolygonShape.new()
#	col_shape.set_faces(triangles.get_faces())
#	col.set_shape(col_shape)
