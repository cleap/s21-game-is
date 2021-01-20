var data: Array
var min_val: float
var max_val: float

func _init(width: int, height: int):
	data = []
	for x in width:
		var temp = []
		for y in height:
			temp.append(0.0)
		data.append(temp)
	min_val = INF
	max_val = -INF

