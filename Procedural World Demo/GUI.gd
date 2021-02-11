extends CanvasLayer


onready var terrain_map: TextureRect = get_node("TerrainRect")
onready var heat_map: TextureRect = get_node("TerrainRect/HeatRect")
onready var moisture_map: TextureRect = get_node("TerrainRect/MoistureRect")
onready var marker: Sprite = get_node("TerrainRect/Sprite")
onready var player = get_node("../Player")

var terrain: Terrain

var found_terrain = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not found_terrain and has_node("../Terrain"):
		terrain = get_node("../Terrain")
		found_terrain = true
		terrain_map.texture = terrain.terrain_texture
		heat_map.texture = terrain.heat_texture
		moisture_map.texture = terrain.moisture_texture
	if found_terrain:
		var pos = Vector2(player.transform.origin.x, player.transform.origin.z)
		pos /= terrain.CHUNK_WIDTH * terrain.NUM_CHUNKS
		pos *= terrain_map.rect_size.x
		marker.position = pos
		marker.rotation = -player.rotation.y
