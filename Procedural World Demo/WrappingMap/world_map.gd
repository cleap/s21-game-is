extends Spatial

const Tile = preload("res://WrappingMap/Tile.gd")
onready var texture = get_node("Texture")

const  MAP_WIDTH = 256
const MAP_HEIGHT = 256
const RAD = MAP_WIDTH / (2.0*PI)

const DEEP_WATER = 0.2
const SHALLOW_WATER = 0.4
const SAND = 0.5
const GRASS = 0.7
const FOREST = 0.8
const ROCK = 0.9
const SNOW = 1.0

const DEEP_COLOR = Color(0, 0, 0.5, 1.0)
const SHALLOW_COLOR = Color(25/255.0, 25/255.0, 150/255.0, 1.0)
const SAND_COLOR = Color(240/255.0, 240/255.0, 64/255.0, 1.0)
const GRASS_COLOR = Color(50/255.0, 220/255.0, 20/255.0, 1.0)
const FOREST_COLOR = Color(16/255.0, 160/255.0, 0.0, 1.0)
const ROCK_COLOR = Color(0.5, 0.5, 0.5, 1)
const SNOW_COLOR = Color.white

export var noise: OpenSimplexNoise

func _ready():
	randomize()
	generate()

func generate():
	noise.seed = randi()
	var tiles: Array = []
	var min_val: float = INF
	var max_val: float = -INF
	
	var temp1 = []
	for x in MAP_WIDTH:
		var theta = lerp(0.0, 2.0*PI, x/float(MAP_WIDTH))
		var temp2: Array = []
		for y in MAP_HEIGHT:
			var val = noise.get_noise_3d(RAD*cos(theta), RAD*sin(theta), y)
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
	
	texture.update(MAP_WIDTH, MAP_HEIGHT, tiles)

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

func _input(event):
	if event.is_action_pressed("ui_accept"):
		generate()
