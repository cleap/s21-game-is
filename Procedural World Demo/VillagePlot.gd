extends Node
class_name VillagePlot

var borders: Rect2
var num_houses: int
var type: String
var origin: Vector3

func _init(borders: Rect2, num_houses: int, type: String, origin: Vector3):
	self.borders = borders
	self.num_houses = num_houses
	self.type = type
	self.origin = origin
