extends Spatial
class_name Terrain

const Tile = preload("res://WrappingMap/Tile.gd")
onready var mesh : MeshInstance = get_node("MeshInstance")

const  MAP_WIDTH = 32 #256
const MAP_HEIGHT = MAP_WIDTH #256
const TILE_WIDTH = 16.0
const RAD = TILE_WIDTH * MAP_WIDTH / (2.0*PI)

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

export var noise : OpenSimplexNoise
var min_val : float
var max_val : float

#func _ready():
#	noise = OpenSimplexNoise.new()
#	noise.period = 150.0
#	randomize()

func _ready():
	noise = OpenSimplexNoise.new()
	noise.period = 150.0
	randomize()
	generate(mesh)

func get_height(val : float):
	
	var sand_mult = 20.0
	var grass_mult = 40.0
	
	if val <= SHALLOW_WATER:
		return 0.0
	elif val <= SAND:
		return (val - SHALLOW_WATER) * sand_mult
	elif val <= FOREST:
		return (val - SAND) * grass_mult + (SAND - SHALLOW_WATER) * sand_mult
	return (pow(10.0*val, (val - FOREST)) - 1.0) * 50.0 + (FOREST - SAND) * grass_mult + (SAND - SHALLOW_WATER) * sand_mult

func generate(mesh: MeshInstance):
	noise.seed = randi()
	var tiles: Array = []
	min_val = INF
	max_val = -INF
	
	var temp1 = []
	for x in MAP_WIDTH:
		var theta = 2.0*PI*x/float(MAP_WIDTH)
		var temp2: Array = []
		for y in MAP_HEIGHT:
			var phi = 2.0*PI*y/float(MAP_HEIGHT)
			var val = noise.get_noise_4d(RAD*cos(theta), RAD*sin(theta), RAD*cos(phi), RAD*sin(phi))
			if val < min_val:
				min_val = val
			if val > max_val:
				max_val = val
			temp2.append(val)
		temp1.append(temp2)
	
	for x in MAP_WIDTH:
		var temp: Array = []
		for y in MAP_HEIGHT:
			var val = temp1[x][y]
			val = (val - min_val) / (max_val - min_val)
			temp.append(Tile.new(get_color(val)))
		tiles.append(temp)
	
#	texture.update(MAP_WIDTH, MAP_HEIGHT, tiles)
	generate_mesh(mesh)

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

func get_square(x, y, lod):
	var pts = []
	var colors = []
	for i in range(2):
		for j in range(2):
			var new_x = TILE_WIDTH*(x + i)/lod
			var new_z = TILE_WIDTH*(y + j)/lod
			var theta = 2.0*PI*new_x/float(MAP_WIDTH * TILE_WIDTH)
			var phi = 2.0*PI*new_z/float(MAP_HEIGHT * TILE_WIDTH)
			var val = noise.get_noise_4d(RAD*cos(theta), RAD*sin(theta), RAD*cos(phi), RAD*sin(phi))
			new_x -= (TILE_WIDTH * MAP_WIDTH / (2.0))
			new_z -= (TILE_WIDTH * MAP_HEIGHT / (2.0))
			val = (val - min_val) / (max_val - min_val)
			colors.push_front(get_color(val))
			pts.push_front(Vector3(new_x, get_height(val), new_z))
	return [pts, colors]

func generate_mesh(mesh: MeshInstance):
	var st: SurfaceTool = SurfaceTool.new()
	var lod = 4.0 #16.0
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(MAP_WIDTH * lod):
		for y in range(MAP_HEIGHT * lod):
			
			var tmp = get_square(x, y, lod)
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

func get_locations(reqs: Array):
	var arr = []
	for req in reqs:
		var width = sqrt(req.area)
		var origin: Vector3 = Vector3.ZERO
		origin.x = (randf() - 0.5) * MAP_WIDTH * TILE_WIDTH
		origin.z = (randf() - 0.5) * MAP_WIDTH * TILE_WIDTH
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

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		generate(mesh)
