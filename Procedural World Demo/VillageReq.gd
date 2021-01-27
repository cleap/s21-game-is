extends Node
class_name VillageReq

var area: float
var num_houses: int
var type: String

func _init(area: float, num_houses: int, type: String):
	self.area = area
	self.num_houses = num_houses
	self.type = type
