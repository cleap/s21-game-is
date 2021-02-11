class_name Tile

const DEEP_WATER = 0.2
const SHALLOW_WATER = 0.4
const SHORE = 0.5
const GRASS = 0.65
const FOREST = 0.8
const ROCK = 0.95
const SNOW = 1.0

const DEEP_COLOR = Color(0, 0, 0.5, 1.0)
const SHALLOW_COLOR = Color(25/255.0, 25/255.0, 150/255.0, 1.0)
const SHORE_COLOR = Color(240/255.0, 240/255.0, 64/255.0, 1.0)
const GRASS_COLOR = Color(50/255.0, 220/255.0, 20/255.0, 1.0)
const FOREST_COLOR = Color(16/255.0, 160/255.0, 0.0, 1.0)
const ROCK_COLOR = Color(0.5, 0.5, 0.5, 1)
const SNOW_COLOR = Color.white

enum LandType {
	DEEP_WATER,
	SHALLOW_WATER,
	BEACH,
	GRASSLAND,
	FOREST,
	MOUTAIN,
	ICE
}

const ICE_COLOR = Color.white
const DESERT_COLOR = Color(238/255.0, 218/255.0, 130/255.0, 1)
const SAVANNA_COLOR = Color(177/255.0, 209/255.0, 110/255.0, 1)
const TROP_RAIN_COLOR = Color(66/255.0, 123/255.0, 25/255.0, 1)
const TUNDRA_COLOR = Color(96/255.0, 131/255.0, 112/255.0, 1)
const TEMP_RAIN_COLOR = Color(29/255.0, 73/255.0, 40/255.0, 1)
const GRASSLAND_COLOR = Color(164/255.0, 1, 99/255.0, 1)
const SEASONAL_FOREST_COLOR = Color(73/255.0, 100/255.0, 35/255.0, 1)
const BOREAL_FOREST_COLOR = Color(95/255.0, 115/255.0, 62/255.0, 1)
const WOODLAND_COLOR = Color(139/255.0, 175/255.0, 90/255.0, 1)

enum Biome {
	OCEAN,
	DEEP_OCEAN,
	MOUNTAIN,
	MOUNTAIN_TOP,
	DESERT,
	SAVANNA,
	TROPICAL_RAINFOREST,
	GRASSLAND,
	WOODLAND,
	SEASONAL_FOREST,
	TEMPERATE_RAINFOREST,
	BOREAL_FOREST,
	TUNDRA,
	ICE
}

const BiomeTable = [
	# Coldest		Colder			Cold					Warm						Warmer						Warmest
	[ Biome.ICE,	Biome.TUNDRA,	Biome.GRASSLAND,		Biome.DESERT, 				Biome.DESERT, 				Biome.DESERT  ],			# Driest
	[ Biome.ICE,	Biome.TUNDRA,	Biome.GRASSLAND, 		Biome.DESERT, 				Biome.DESERT,				Biome.DESERT  ],			# Drier
	[ Biome.ICE,	Biome.TUNDRA,	Biome.WOODLAND, 		Biome.WOODLAND, 			Biome.SAVANNA,				Biome.SAVANNA ],			# Dry
	[ Biome.ICE,	Biome.TUNDRA,	Biome.BOREAL_FOREST,	Biome.WOODLAND, 			Biome.SAVANNA,				Biome.SAVANNA ],			# Wet
	[ Biome.ICE,	Biome.TUNDRA,	Biome.BOREAL_FOREST,	Biome.SEASONAL_FOREST, 		Biome.TROPICAL_RAINFOREST, 	Biome.TROPICAL_RAINFOREST], # Wetter
	[ Biome.ICE,	Biome.TUNDRA,	Biome.BOREAL_FOREST,	Biome.TEMPERATE_RAINFOREST,	Biome.TROPICAL_RAINFOREST, 	Biome.TROPICAL_RAINFOREST], # Wettest
]

const COLDEST_VALUE = 1/7.0
const COLDER_VALUE = 2/7.0
const COLD_VALUE = 3/7.0
const WARM_VALUE = 4/7.0
const WARMER_VALUE = 5/7.0

const COLDEST_COLOR = Color(0,1,1,1)
const COLDER_COLOR = Color(170/255.0,1,1,1)
const COLD_COLOR = Color(0,229/255.0,133/255.0,1)
const WARM_COLOR = Color(1,1,100/255.0,1)
const WARMER_COLOR = Color(1,100/255.0,0,1)
const WARMEST_COLOR = Color(241/255.0,12/255.0,0,1)

enum Heat {
	COLDEST,
	COLDER,
	COLD,
	WARM,
	WARMER,
	WARMEST
}

const DRIEST_VALUE = 0.27
const DRIER_VALUE = 0.4
const DRY_VALUE = 0.6
const WET_VALUE = 0.8
const WETTER_VALUE = 0.9

const DRIEST_COLOR = Color(1, 139/255.0, 17/255.0, 1)
const DRIER_COLOR = Color(245/255.0, 245/255.0, 23/255.0, 1)
const DRY_COLOR = Color(80/255.0, 1, 0, 1)
const WET_COLOR = Color(85/255.0, 1, 1, 1)
const WETTER_COLOR = Color(20/255.0, 70/255.0, 1, 1)
const WETTEST_COLOR = Color(0, 0, 100/255.0, 1)

enum Moisture {
	DRIEST,
	DRIER,
	DRY,
	WET,
	WETTER,
	WETTEST
}

var height: float
var moisture: float
var heat: float

var biome
var is_edge: bool
var color: Color
var heat_color: Color
var moisture_color: Color

var x: int
var y: int
var up
var down
var left
var right

func _init(x, y, height, heat_val, moisture_val):
	self.x = x
	self.y = y
	self.height = height
	self.biome = LandType.DEEP_WATER
	self.color = Color.fuchsia
	set_heat(heat_val)
	set_moisture(moisture_val)
	set_biome()

func set_neighbors(up, down, left, right):
	self.up = up
	self.down = down
	self.left = left
	self.right = right

func set_heat(heat_val):
	
	if height <= SHORE:
		pass
	elif height <= GRASS:
		heat_val -= 0.1*height
	elif height <= FOREST:
		heat_val -= 0.2*height
	elif height <= ROCK:
		heat_val -= 0.3*height
	else:
		heat_val -= 0.4*height
	
	if heat_val <= COLDEST_VALUE:
		heat = Heat.COLDEST
		heat_color = COLDEST_COLOR
	elif heat_val <= COLDER_VALUE:
		heat = Heat.COLDER
		heat_color = COLDER_COLOR
	elif heat_val <= COLD_VALUE:
		heat = Heat.COLD
		heat_color = COLD_COLOR
	elif heat_val <= WARM_VALUE:
		heat = Heat.WARM
		heat_color = WARM_COLOR
	elif heat_val <= WARMER_VALUE:
		heat = Heat.WARMER
		heat_color = WARMER_COLOR
	else:
		heat = Heat.WARMEST
		heat_color = WARMEST_COLOR

func set_moisture(moisture_val):
	
	if height <= SHALLOW_WATER:
		moisture_val = 1
	elif height <= SHORE:
		moisture += 0.25 * height
	
	if moisture_val <= DRIEST_VALUE:
		moisture = Moisture.DRIEST
		moisture_color = DRIEST_COLOR
	elif moisture_val <= DRIER_VALUE:
		moisture = Moisture.DRIER
		moisture_color = DRIER_COLOR
	elif moisture_val <= DRY_VALUE:
		moisture = Moisture.DRY
		moisture_color = DRY_COLOR
	elif moisture_val <= WET_VALUE:
		moisture = Moisture.WET
		moisture_color = WET_COLOR
	elif moisture_val <= WETTER_VALUE:
		moisture = Moisture.WETTER
		moisture_color = WETTER_COLOR
	else:
		moisture = Moisture.WETTEST
		moisture_color = WETTEST_COLOR

func get_biome(heat, moisture):
	return BiomeTable[heat][moisture]

func set_biome():
	if height <= DEEP_WATER:
		biome = Biome.DEEP_OCEAN
	elif height <= SHALLOW_WATER:
		biome = Biome.OCEAN
	elif height <= FOREST:
		biome = BiomeTable[moisture][heat]
	elif height <= ROCK:
		biome = Biome.MOUNTAIN
	else:
		biome = Biome.MOUNTAIN_TOP

func update_color():
	
	
	
#	OCEAN,
#	DEEP_OCEAN,
#	MOUNTAIN,
#	MOUNTAIN_TOP,
#	DESERT,
#	SAVANNA,
#	TROPICAL_RAINFOREST,
#	GRASSLAND,
#	WOODLAND,
#	SEASONAL_FOREST,
#	TEMPERATE_RAINFOREST,
#	BOREAL_FOREST,
#	TUNDRA,
#	ICE
	
	match biome:
		Biome.DEEP_OCEAN:
			color = DEEP_COLOR
		Biome.OCEAN:
			color = SHALLOW_COLOR
		Biome.MOUNTAIN:
			color = ROCK_COLOR
		Biome.MOUNTAIN_TOP:
			color = SNOW_COLOR
		Biome.DESERT:
			color = DESERT_COLOR
		Biome.SAVANNA:
			color = SAVANNA_COLOR
		Biome.TROPICAL_RAINFOREST:
			color = TROP_RAIN_COLOR
		Biome.GRASSLAND:
			color = GRASSLAND_COLOR
		Biome.WOODLAND:
			color = WOODLAND_COLOR
		Biome.SEASONAL_FOREST:
			color = SEASONAL_FOREST_COLOR
		Biome.TEMPERATE_RAINFOREST:
			color = TEMP_RAIN_COLOR
		Biome.BOREAL_FOREST:
			color = BOREAL_FOREST_COLOR
		Biome.TUNDRA:
			color = TUNDRA_COLOR
		Biome.ICE:
			color = ICE_COLOR
		_:
			color = Color.red
	
#	if biome == LandType.DEEP_WATER:
#		color = DEEP_COLOR
#	elif biome == LandType.SHALLOW_WATER:
#		color = SHALLOW_COLOR
#	elif biome == LandType.BEACH:
#		color = SHORE_COLOR
#	elif biome == LandType.GRASSLAND:
#		color = GRASS_COLOR
#	elif biome == LandType.FOREST:
#		color = FOREST_COLOR
#	elif biome == LandType.MOUTAIN:
#		color = ROCK_COLOR
#	else:
#		color = SNOW_COLOR
	if (biome != up.biome) or \
	   (biome != down.biome) or \
	   (biome != left.biome) or \
	   (biome != right.biome):
		color = lerp(color, Color.black, 0.4)
		heat_color = lerp(heat_color, Color.black, 0.4)
		moisture_color = lerp(moisture_color, Color.black, 0.4)

func get_terrain_color():
	return color
func get_heat_color():
	return heat_color
func get_moisture_color():
	return moisture_color
