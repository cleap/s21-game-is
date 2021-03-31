extends Entity

onready var Port_Front_Leg = get_node("Port_Front/Leg")
onready var Port_Front_Ray = get_node("Port_Front/RayCast")
onready var Port_Front_Dot = get_node("Port_Front/Dot")

onready var Starboard_Front_Leg = get_node("Starboard_Front/Leg")
onready var Starboard_Front_Ray = get_node("Starboard_Front/RayCast")
onready var Starboard_Front_Dot = get_node("Starboard_Front/Dot")

func _ready():
	legs = [
		[Port_Front_Leg, Port_Front_Ray, Port_Front_Dot, Port_Front_Ray.transform.origin],
		[Starboard_Front_Leg, Starboard_Front_Ray, Starboard_Front_Dot, Starboard_Front_Ray.transform.origin]
	]
