extends CanvasLayer


onready var map: TextureRect = get_node("TextureRect")
onready var marker: Sprite = get_node("TextureRect/Sprite")
onready var player = get_node("../Player")

var terrain: Terrain

var found_terrain = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not found_terrain and has_node("../Terrain"):
		terrain = get_node("../Terrain")
		found_terrain = true
		map.texture = terrain.map_texture
	if found_terrain:
		var pos = Vector2(player.transform.origin.x, player.transform.origin.z)
		pos /= terrain.CHUNK_WIDTH * terrain.NUM_CHUNKS
		pos *= map.rect_size.x
		marker.position = pos
