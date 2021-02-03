extends NinePatchRect


onready var map: TextureRect = get_node("TextureRect")
var terrain

var found_terrain = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not found_terrain and has_node("../Terrain"):
		terrain = get_node("../Terrain")
		found_terrain = true
		map.texture = terrain.map_texture
