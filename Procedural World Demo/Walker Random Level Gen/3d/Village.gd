extends Node
class_name Village

const Walker_3d = preload("res://Walker Random Level Gen/3d/walker_3d.tscn")

func gen_villages(plots: Array):
	var AR = []
	for plot in plots:
		print(plot.type)
		#var gen_vill = Cave.new()
		AR.append(Walker_3d.instance())
		#AR.apeend(gen_vill)
	return AR
