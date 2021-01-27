extends Node
class_name VillagePlot

var borders: Rect2
var num_houses: int
var type: String

func _init(borders: Rect2, num_houses: int, type: String):
	self.borders = borders
	self.num_houses = num_houses
	self.type = type
