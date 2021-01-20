extends MeshInstance

const Tile = preload("res://WrappingMap/Tile.gd")

func update(width: int, height: int, tiles: Array):
	var image_texture = ImageTexture.new()
	var dynImage = Image.new()
	
	dynImage.create(width, height, false, Image.FORMAT_RGB8)
	dynImage.lock()
	for x in width:
		for y in height:
			var tile: Tile = tiles[x][y]
			dynImage.set_pixel(x, y, tile.get_color())
	dynImage.unlock()
	
	image_texture.create_from_image(dynImage)
	get_surface_material(0).albedo_texture = image_texture
