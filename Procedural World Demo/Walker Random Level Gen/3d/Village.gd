extends Node
class_name Village

const Walker_3d = preload("res://Walker Random Level Gen/3d/walker_3d.tscn")

static func gen_village(plot: VillagePlot):
	var vill = Walker_3d.instance()
	vill
	return vill
